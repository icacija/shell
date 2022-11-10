# /bin/bash

# path to dir
DIR='/home/admin/admin_backups'

# days to hodl
DAYS='2'

find $DIR -ctime +$DAYS -exec rm -rfv {} +
