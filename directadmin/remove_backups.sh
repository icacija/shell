#!/bin/sh

backup_directory="/home/admin/admin_backups" # No trailing /
backup_time="1" # Remove backups how many days old? Number variable only!


# find $backup_directory -mtime +$backup_time -exec rm -rf {} +
find $backup_directory -mtime +$backup_time
