# /bin/bash

# Disable services in WHM
whmapi1 configureservice service=cpsrvd enabled=1 monitored=0
whmapi1 configureservice service=mysql enabled=1 monitored=0
whmapi1 configureservice service=httpd enabled=1 monitored=0

# Stop services
/scripts/restartsrv_cpsrvd --stop
/scripts/restartsrv_mysql --stop
/scripts/restartsrv_httpd --stop

# umout /tmp
umount -l /tmp
umount -l /var/tmp

# Backup
mv /usr/tmpDSK /usr/tmpDSK_bak

# Make new tmp
/scripts/securetmp

# Start Services
/scripts/restartsrv_cpsrvd --start
/scripts/restartsrv_mysql --start
/scripts/restartsrv_httpd --start

# Enable WHM services
whmapi1 configureservice service=cpsrvd enabled=1 monitored=1
whmapi1 configureservice service=mysql enabled=1 monitored=1
whmapi1 configureservice service=httpd enabled=1 monitored=1
