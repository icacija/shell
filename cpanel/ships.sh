#!/bin/bash

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

# Update the system
echo "Updating the system..."
dnf update -y

# Install EPEL repository
echo "Installing EPEL repository..."
dnf config-manager --set-enabled epel

# 1. Update php.ini with specified values

PHPINI_PATH="/opt/cpanel/ea-php74/root/etc/php.ini"

# Backup the original php.ini file
cp $PHPINI_PATH ${PHPINI_PATH}.backup

# Function to update or add a configuration
update_config() {
    local key=$1
    local value=$2

    if grep -q "^$key" $PHPINI_PATH; then
        sed -i "s|^$key.*|$key = $value|" $PHPINI_PATH
    else
        echo "$key = $value" >> $PHPINI_PATH
    fi
}

# Update configurations
echo "Updating php.ini..."
update_config "allow_url_fopen" "On"
update_config "memory_limit" "-1"
update_config "session.gc_maxlifetime" "31536000"
update_config "post_max_size" "500M"
update_config "upload_max_filesize" "500M"
update_config "max_input_vars" "10000"
update_config "max_input_time" "600"
update_config "max_execution_time" "300"
update_config "disable_functions" "exec,system,passthru,shell_exec,dl,show_source,posix_kill,posix_mkfifo,posix_getpwuid,posix_setpgid,posix_setsid,posix_setuid,posix_setgid,posix_seteuid,posix_setegid,posix_uname"
update_config "session.cookie_samesite" "Lax"
update_config "session.cookie_secure" "1"

# Ensure cPanel scripts are up-to-date
/usr/local/cpanel/scripts/upcp

# 2. Install Redis and configure

echo "Installing Redis..."
yum install -y redis

# Get the total RAM in KB and calculate 1/4 of the installed RAM
TOTAL_RAM_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
TOTAL_RAM_MB=$((TOTAL_RAM_KB / 1024))
REDIS_MAX_MEMORY=$((TOTAL_RAM_MB / 4))M

# Disable snapshotting in Redis configuration
echo "Configuring Redis..."
sed -i 's/^save /#save /' /etc/redis.conf

# Set the maxmemory limit and policy in Redis configuration
echo "maxmemory $REDIS_MAX_MEMORY" >> /etc/redis.conf
echo "maxmemory-policy allkeys-lfu" >> /etc/redis.conf

# Start and enable Redis service
echo "Starting and enabling Redis service..."
systemctl start redis
systemctl enable redis

# 3. Install Opcache, Fileinfo, Imagemagick, Redis extensions

echo "Installing Opcache and Fileinfo"
yum install ea-php74-php-opcache ea-php74-php-fileinfo

echo "Installing Imagick dependencies..."
yum install -y ImageMagick ImageMagick-devel

echo "Installing Imagick..."
/opt/cpanel/ea-php74/root/usr/bin/pecl install imagick

echo "Installing Redis..."
/opt/cpanel/ea-php74/root/usr/bin/pecl install redis

# Enable the installed extensions in php.ini
# echo "Enabling extensions in php.ini..."
# echo "extension=opcache.so" >> /opt/cpanel/ea-php74/root/etc/php.ini
# echo "extension=fileinfo.so" >> /opt/cpanel/ea-php74/root/etc/php.ini
# echo "extension=imagick.so" >> /opt/cpanel/ea-php74/root/etc/php.ini
# echo "extension=redis.so" >> /opt/cpanel/ea-php74/root/etc/php.ini

# Restart Apache to apply changes
echo "Restarting Apache..."
/usr/local/cpanel/scripts/restartsrv_httpd

# 4. Install Composer and update to version 1

# Install necessary dependencies
echo "Installing dependencies for Composer..."
# yum install -y curl wget php-cli php-zip unzip

# Download and install Composer
echo "Downloading and installing Composer..."
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Verify Composer installation
if [ -f /usr/local/bin/composer ]; then
  echo "Composer installed successfully."
else
  echo "Composer installation failed."
  exit 1
fi

# Update Composer to version 1
echo "Updating Composer to version 1..."
composer self-update --1

# Verify the update
if composer --version | grep -q "Composer version 1"; then
  echo "Composer updated to version 1 successfully."
else
  echo "Composer update to version 1 failed."
  exit 1
fi

echo "All tasks completed successfully."
