# /bin/bash
dir="/backup/db"
if [ ! -d $dir ]
then
    mkdir $dir
else
    cd $dir
    mkdir $(date +"%Y-%m-%d")
    cd $(date +"%Y-%m-%d")
    for I in $(mysql -e 'show databases' -s --skip-column-names); do mysqldump2 $I | gzip > "$I.sql.gz"; done
    cd $dir
    echo -e "Cleaning old bkps"
    find $dir/* -mtime +2 -exec rm -rf {} \;
fi
