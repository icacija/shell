#!/bin/sh

version="1.3"
backup_directory="/home/admin/admin_backups" # No trailing /
backup_time="2" # Remove backups how many days old? Number variable only!


# find $backup_directory -mtime +$backup_time -exec rm -rf {} +
# find $backup_directory -maxdepth 1 -type f -mtime $backup_time
find $backup_directory -maxdepth 1 -type f -mtime $backup_time -exec rm -rf {} +

echo -e "Thank you for using Remove_backups $version"
