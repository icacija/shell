#!/bin/sh

# Script path /usr/local/directadmin/scripts/custom/user_backup_post.sh
# chmod 755 /usr/local/directadmin/scripts/custom/user_backup_post.sh

#set reseller
RESELLER=admin

BACKUP_PATH=`echo $file | cut -d/ -f1,2,3,4`
REQUIRED_PATH=/home/$RESELLER/admin_backups

if [ "$BACKUP_PATH" = "$REQUIRED_PATH" ]; then
   if [ "`echo $file | cut -d. -f4,5`" = "tar.zst" ]; then
       NEW_FILE=`echo $file | cut -d. -f1,2,3`.`date +%F-%H_%M`.tar.zst
       if [ -s "$file" ] && [ ! -e "$NEW_FILE" ]; then
           mv $file $NEW_FILE
       fi
   fi
fi
exit 0;
