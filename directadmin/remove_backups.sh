#!/bin/sh

backup_directory="/home/admin/admin_backups" # No trailing /
backup_time="1" # Remove backups how many days old? Number variable only!

#### Commands ####

find_files="find $backup_directory -maxdepth +1 -mtime +$backup_time"

#### Begin Script ####

echo ""
echo "Looking for old backups... Older then $backup_time days old."
echo "----"
if [ -z "$find_files" ]; then                 
echo "None Found!"
else
echo "$find_files"
fi
echo "----"
echo ""
echo "If any folders were found they have deleted."
# find $backup_directory -mtime +$backup_time -exec rm -rf {} +
echo ""
echo "Done."
echo ""
