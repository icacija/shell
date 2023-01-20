#!/usr/local/cpanel/3rdparty/bin/perl

# cpanel - scripts/securetmp                       Copyright 2022 cPanel, L.L.C.
#                                                           All rights reserved.
# copyright@cpanel.net                                         http://cpanel.net
# This code is subject to the cPanel license. Unauthorized copying is prohibited

use strict;
use warnings;

use Cpanel::TempFile           ();
use Cpanel::SafeFile           ();
use Cpanel::Filesys::FindParse ();
use Cpanel::DiskLib            ();
use Getopt::Long;
use Cpanel::Logger          ();
use Cpanel::SafeRun::Errors ();
use Cpanel::SafeRun::Simple ();
use Cpanel::Filesys::Mounts ();
my $logger = Cpanel::Logger->new();

$| = 1;    ## no critic qw(RequireLocalizedPunctuationVars)

my $has_loop_device = 0;

my $install   = 0;    # Add securetmp to system startup
my $uninstall = 0;    # Remove from system startup
my $auto      = 0;    # Secure /tmp and /var/tmp
my $daemonize = 1;
my $help      = 0;

# Get command line options
GetOptions( 'auto' => \$auto, 'install' => \$install, 'uninstall' => \$uninstall, 'daemonize!' => \$daemonize, 'help' => \$help );

if ($help) {
    print <<"MANUAL";
$0 - secure /tmp and /var/tmp

Options:
- auto: skip interactive customization questions
- install: install & enable securetmp service
- uninstall: disable & uninstal securetmp service
- daemonize: run securetmp in background ( default true )

Sample usages:
# run in interactive mode
> $0

# disable interactive mode, run in background
> $0 --auto

# disable interactive mode, do not run in background
> $0 --auto --nodaemonize
MANUAL
    exit;
}

if ( -e '/var/cpanel/version/securetmp_disabled' ) {
    print "[securetmp] Disabled per /var/cpanel/version/securetmp_disabled\n";
    exit;
}
elsif ( -e '/var/cpanel/disabled/securetmp' ) {
    print "[securetmp] Disabled per /var/cpanel/disabled/securetmp\n";
    exit;
}

# do check for loopback module for Linux based VPS
my @modules = Cpanel::SafeRun::Errors::saferunallerrors('lsmod');
$has_loop_device = check_loop_device();

if ( !grep /loop/, @modules ) {
    print "*** Notice *** No loop module detected\n";    # could be built into kernel, so don't bail out yet
    print "If the loopback block device is built as a module, try running `modprobe loop` as root via ssh and running this script again.\n";
    print "If the loopback block device is built into the kernel itself, you can ignore this message.\n";
}
if ( !$has_loop_device ) {
    print "*** Notice *** No working loopback device files found. Try running `modprobe loop` as root via ssh and running this script again.\n";
    exit(0);
}

# Start interactive setup
if ( !$auto && !$install && !$uninstall && -t STDIN ) {
    print 'Would you like to secure /tmp & /var/tmp at boot time? (y/n) ';
    my $answer;
    chomp( $answer = <STDIN> );
    if ( $answer =~ m/^y/i ) {
        $install = 1;
    }
    else {
        print "securetmp will not be added to system startup at this time.\n";
    }
    undef $answer;

    if ( !$install ) {
        print 'Would you like to disable securetmp from the system startup? (y/n) ';
        chomp( $answer = <STDIN> );
        if ( $answer =~ m/^y/i ) {
            $uninstall = 1;
        }
        else {
            print "securetmp will not be removed from system startup.\n";
        }
        undef $answer;
    }

    print 'Would you like to secure /tmp & /var/tmp now? (y/n) ';
    chomp( $answer = <STDIN> );
    if ( $answer =~ m/^y/i ) {
        $auto = 1;
    }
    else {
        print "/tmp & /var/tmp will not be secured at this time.\n";
    }

    exit if ( !$install && !$auto && !$uninstall );
}
elsif ( !$auto && !$install && !$uninstall ) {
    exit 1;
}

## ADD/REMOVE from startup
#-----------------------------------------------------------------

if ( !-x '/usr/local/cpanel/scripts/cpservice' ) {
    $logger->warn("cpservice is not available. Please check its status.");
}
else {

    # Remove securetmp from system startup
    if ($uninstall) {
        Cpanel::SafeRun::Simple::saferun( '/usr/local/cpanel/scripts/cpservice', 'securetmp', 'stop' );
        Cpanel::SafeRun::Simple::saferun( '/usr/local/cpanel/scripts/cpservice', 'securetmp', 'disable', '2345' );
        Cpanel::SafeRun::Simple::saferun( '/usr/local/cpanel/scripts/cpservice', 'securetmp', 'uninstall' );
    }

    # Add securetmp to system startup
    if ($install) {
        Cpanel::SafeRun::Simple::saferun( '/usr/local/cpanel/scripts/cpservice', 'securetmp', 'install' );
        Cpanel::SafeRun::Simple::saferun( '/usr/local/cpanel/scripts/cpservice', 'securetmp', 'enable', '35' );

        # Do not start securetmp here or it will be run again
    }

}

#-----------------------------------------------------------------

# Fork and secure if not called from console
if ( $auto && !-t STDIN && $daemonize ) {
    $SIG{'CHLD'} = \&reaper;
    print "Setting up /tmp & /var/tmp in the background\n";
    exit if fork;
}
elsif ( !$auto ) {
    exit;
}

print "Securing /tmp & /var/tmp\n";

# Secure PATH
$ENV{'PATH'} .= ":/sbin:/usr/sbin";

# Global Variables
my $brokenvartmp = 0;
my @vnodes       = ();
my $vnodeconfig  = '';
my $vnodesrch    = '';
my $vnodenumber  = 0;
my $tmpmnt       = '';
my $vartmpmnt    = '';
my $tmpopts      = '';
my $vartmpopts   = '';
my $mountkeyword = '';
my $cpflags      = '';
my $tmpdsksize   = 512000;    # Must be larger than 250000

$mountkeyword = 'remount';
$cpflags      = '-af';

if ( open my $mounts_fh, '<', '/proc/mounts' ) {
    while ( my $line = readline $mounts_fh ) {

        # must detect: /dev/sda1 /var/tmp\040(deleted) ext2 rw,nosuid,noexec,usrquota 0 0
        if ( $line =~ m/^(\S+)\s+([^\s\\\(]+)\S*\s+\S+\s+(\S+)/ ) {
            if ( $2 eq '/tmp' ) {
                $tmpmnt  = $1;
                $tmpopts = $3;
            }
            elsif ( $2 eq '/var/tmp' ) {
                $vartmpmnt  = $1;
                $vartmpopts = $3;
            }
            if ( $1 =~ /^\/dev\/vn.*/ ) {
                push @vnodes, $1;
            }
        }

        if ( $line =~ m/\S+\s+\(deleted\)[^\/]*\/var\/tmp\s+/ ) {
            $brokenvartmp = 1;
            $vartmpmnt    = '';
            $vartmpopts   = '';
        }
    }
    close $mounts_fh;
}
else {
    die "Unable to read /proc/mounts: $!";
}

# Begin securetmp actions
if ( !$tmpmnt ) {

    print "Calculating size on /tmp\n";
    my $partition_map = {};
    my $filesys       = Cpanel::DiskLib::get_disk_used_percentage_with_dupedevs();
    foreach my $disk ( @{$filesys} ) {
        $partition_map->{ $disk->{'mount'} } = $disk->{'available'};
    }
    my $mount_point = Cpanel::Filesys::FindParse::find_mount( $filesys, '/usr/tmpDSK' );

    my $available                 = $partition_map->{$mount_point};
    my $five_percent_of_available = ( $available * 0.05 );
    if ( $five_percent_of_available > $tmpdsksize ) {
        $tmpdsksize = $five_percent_of_available;
    }
    my $FOUR_GIG_k = ( 1024 * 1024 * 4 );
    if ( $tmpdsksize > $FOUR_GIG_k ) {
        $tmpdsksize = $FOUR_GIG_k;
    }

    $tmpdsksize = int($tmpdsksize);
    $tmpdsksize = $tmpdsksize - ( $tmpdsksize % 1024 );

    my $tmpdsksize_megs = ( $tmpdsksize / 1024 );
    print "/tmp calculated to be $tmpdsksize_megs M based on available disk space in /usr\n";

    # Check loop dev on Linux
    if ( !$has_loop_device ) {
        print "The system does not support loop devices.\n";
        if ($brokenvartmp) {
            print 'Unmounting orphaned /var/tmp ...';
            system 'umount', '/var/tmp';
            print "Done\n";
        }
        exit;
    }

    if ( -d '/usr/tmpDSK' ) {
        rename( '/usr/tmpDSK', '/usr/tmpDSK.move_away.' . $$ . '.' . time() );
    }

    if ( !-e '/usr/tmpDSK' ) {
        print "No separate partition for tmp!\n";
        createtmpdisk('/usr/tmpDSK');
    }
    elsif ( -d '/usr/tmpDSK' ) {
        die "/usr/tmpDSK exists as a directory. Please remove and rerun /usr/local/cpanel/scripts/securetmp.\n";
    }

    # ensure that /usr/tmpDSK is large enough
    elsif ( ( -s '/usr/tmpDSK' ) < ( $tmpdsksize * 1024 ) ) {
        print "Your /tmp is too small.   Rebuilding it now.\n";
        system 'rm', '-f', '/usr/tmpDSK';
        createtmpdisk('/usr/tmpDSK');
    }
    else {
        print "Everything looks good with your /tmp.  Its the right size and ready to go.\n";
    }
    print 'Setting up /tmp... ';
    if ( -e '/usr/tmp.secure' ) {
        system 'mv', '-f', '/usr/tmp.secure', '/usr/tmp.secure.cpback';
    }
    mkdir '/usr/tmp.secure';
    archivecopy( '/tmp', '/usr/tmp.secure' );
    system 'rm', '-rf', '/tmp';
    mkdir '/tmp';
    chmod( oct(1777), '/tmp' );
    my $mountresult = mounttmpdsk( '/usr/tmpDSK', '/tmp', $tmpopts );
    archivecopy( '/usr/tmp.secure/tmp/.', '/tmp' );
    chmod( oct(1777), '/tmp' );
    system 'rm', '-rf', '/usr/tmp.secure';

    if ($mountresult) {
        die "There was a problem mounting /tmp: $mountresult";
    }
    print "Done\n";
}
elsif ( $tmpmnt && $tmpopts !~ m/noexec/ ) {
    print 'Securing /tmp... ';
    system 'mount', '-o', $mountkeyword . ',noexec,nosuid', $tmpmnt, '/tmp';
    print "Done\n";
}
else {
    print "/tmp is already secure\n";
}

if ( $brokenvartmp || ( $vartmpmnt && $vartmpopts !~ m/noexec/ ) ) {
    print 'Unmounting insecure /var/tmp... ';
    system 'umount', '/var/tmp';
    $vartmpmnt  = '';
    $vartmpopts = '';
    print "Done\n";
}

if ( !$vartmpmnt ) {
    print 'Setting up /var/tmp... ';

    if ( !-e '/var/tmp' ) {
        mkdir '/var/tmp';
    }
    elsif ( !-d '/var/tmp' ) {
        system 'mv', '/var/tmp', '/var/tmp.cpback';
        mkdir '/var/tmp';
    }

    system 'mount', '-o', 'bind,noexec,nosuid', '/tmp', '/var/tmp';
    print "Done\n";
}
else {
    print "/var/tmp is already secure\n";
}

my $usingTMPDSK = 0;
if ( -e '/usr/tmpDSK' ) {
    my $mount = `mount`;
    if ( $mount =~ m/tmpDSK/ ) {
        $usingTMPDSK = 1;
    }
}

print 'Checking fstab for entries ...';
my $hastmpdsk    = 0;
my $hasvartmpdsk = 0;
my $fslock       = Cpanel::SafeFile::safeopen( \*FSTAB, '+<', '/etc/fstab' );
if ($fslock) {
    while (<FSTAB>) {
        if (/^\s*\/usr\/tmpDSK/)      { $hastmpdsk    = 1; }
        if (/^\s*(\S+)\s*\/var\/tmp/) { $hasvartmpdsk = 1; }
    }

    if ( !$hastmpdsk && $usingTMPDSK ) {
        print "Added fstab entry (/tmp)....";
        print FSTAB "/usr/tmpDSK             /tmp                    ext3    defaults,noauto        0 0\n";
    }
    if ( !$hasvartmpdsk && $vartmpmnt ) {
        print "Added fstab entry (/var/tmp)....";
        print FSTAB "/tmp             /var/tmp                    ext3    defaults,bind,noauto        0 0\n";
    }

    Cpanel::SafeFile::safeclose( \*FSTAB, $fslock );
    print "Done\n";
}
else {
    $logger->die("Could not edit /etc/fstab");
}

my $logrotate = '/etc/cron.daily/logrotate';
if ( -e $logrotate ) {
    my @logrotate_contents;
    my $has_tmpdir = 0;
    if ( open my $logrotate_fh, '<', $logrotate ) {
        while ( my $line = readline $logrotate_fh ) {
            if ( $line =~ m/TMPDIR/ && $line !~ m/^\s*#/ ) {
                $has_tmpdir = 1;
                last;
            }
            push @logrotate_contents, $line;
        }
        close $logrotate_fh;

        if ( !$has_tmpdir ) {
            my $updated_logrotate = 0;
            if ( open my $logrotate_fh, '>', $logrotate ) {
                foreach my $line (@logrotate_contents) {
                    if ( $line =~ m/^#!\/(?:usr|bin)/ ) {
                        print "Adding TMPDIR setting to /etc/cron.daily/logrotate\n";
                        print {$logrotate_fh} $line;
                        print {$logrotate_fh} "export TMPDIR=/var/spool/logrotate/tmp\n";
                        $updated_logrotate = 1;
                    }
                    else {
                        print {$logrotate_fh} $line;
                    }
                }
                close $logrotate_fh;
            }
            if ($updated_logrotate) {
                if ( !-e '/var/spool/logrotate/tmp' ) {
                    system 'mkdir', '-p', '/var/spool/logrotate/tmp';
                }
                if ( !-d '/var/spool/logrotate/tmp' ) {
                    print <<'EOM';
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
Logrotate detected and TMPDIR setting updated. The TMPDIR
directory (/var/spool/logrotate/tmp) does not exist!

Logrotate will need to use this directory for execution of
its postrotate scripts. This directory is normally /tmp, but
due to /tmp being set as non-executable an alternative
directory must be specified. Please correct this issue.

See /etc/cron.daily/logrotate to adjust the TMPDIR value for your system.
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
EOM
                }
            }
            else {
                warn "Failed to update /etc/cron.daily/logrotate! Logrotate may be corrupt.";
            }
        }
        else {
            print "Logrotate TMPDIR already configured\n";
        }
    }
}

print "Process Complete\n";

Cpanel::Filesys::Mounts::clear_mounts_cache();

exit;

################################################################################
# createtmpdisk
################################################################################
sub createtmpdisk {
    my $path      = shift;
    my $disk_size = shift || $tmpdsksize;

    local $ENV{'LC_ALL'} = 'C';    # Force prompt processing to english

    print "Building ${path}...";
    if ( -e $path ) {
        unlink($path);
    }
    my $disk_size_in_m = int( $disk_size / 1024 ) || 1;
    my $bytes          = 1024 * 1024 * $disk_size_in_m;
    open( my $fh, '>', $path ) or die "Failed to open â€ś$pathâ€ť: $!";
    truncate( $fh, $bytes ) or do {
        die "truncate($path, $bytes): $!";
    };
    close($fh);

    open( my $mkfs, "|-" ) || exec( "/sbin/mkfs", $path );
    print {$mkfs} "yes\r\n";
    close($mkfs);
    if ( -e "/sbin/tune2fs" ) {
        system( "/sbin/tune2fs", "-j", $path );
    }

    chmod 0600, $path;
    print "Done\n";
    return;
}

################################################################################
# archivecopy
################################################################################
sub archivecopy {
    my ( $origin, $dest ) = @_;

    my $cpflags = '-af';
    return system( "cp", $cpflags, $origin, $dest );
}

################################################################################
# mounttmpdsk
################################################################################
sub mounttmpdsk {
    my ( $disk_path, $mount_path, $current_mount_opts ) = @_;

    $current_mount_opts //= '';

    # Try to mount ext4 + discard first; if that fails, let the system detect the filesystem.
    if ( $current_mount_opts !~ m/loop/ ) {
        if ( system( 'mount', '-t', 'ext4', '-o', 'loop,noexec,nosuid,rw,discard', $disk_path, $mount_path ) ) {
            system( 'mount', '-o', 'loop,noexec,nosuid,rw', $disk_path, $mount_path );
        }
    }
    return (0);
}

sub test_loopback_device {
    my $loopback_device = shift;

    system( 'umount', '/usr/testDSK' );

    createtmpdisk( '/usr/testDSK', 10240 );

    my $tmpfile         = Cpanel::TempFile->new();
    my $test_mount_path = $tmpfile->dir();

    mounttmpdsk( '/usr/testDSK', $test_mount_path );

    my $loopback_status = Cpanel::SafeRun::Errors::saferunallerrors( 'losetup', $loopback_device );

    system( 'umount', $test_mount_path );
    unlink( '/usr/testDSK', $test_mount_path );

    return $loopback_status =~ m/\Q$loopback_device\E:.*\/usr\/testDSK/i ? 1 : 0;
}

sub check_loop_device {
    my $loopback_device = Cpanel::SafeRun::Errors::saferunallerrors( 'losetup', '-f' );

    chomp $loopback_device;

    return if !$loopback_device || !test_loopback_device($loopback_device);

    return $loopback_device;
}

################################################################################
# reaper
################################################################################
sub reaper {
    my $thedead;
    while ( ( $thedead = waitpid( -1, 1 ) ) > 0 ) {

        # the dead shall do what ?
    }
    $SIG{CHLD} = \&reaper;
}
