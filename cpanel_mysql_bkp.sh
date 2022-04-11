# /bin/bash
cd /backup/db
mkdir $(date +"%Y-%m-%d")
cd $(date +"%Y-%m-%d")
for I in $(mysql -e 'show databases' -s --skip-column-names); do mysqldump2 $I | gzip > "$I.sql.gz"; done
echo -e "Cleaning old bkps"
find /backup/db/* -mtime +2 -exec rm -rf {} \;
