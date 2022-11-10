# /bin/bash

#Get script path
SCRIPT=$(readlink -f "$0")

cd /usr/local/directadmin/custombuild
./build update
./build update_da
./build set webserver nginx_apache
./build set php1_mode php-fpm
./build set php2_mode php-fpm
./build set php3_mode php-fpm
./build set php4_mode php-fpm
./build nginx_apache
./build php n
./build rewrite_confs

echo -e "Clean up"
rm -rf "$SCRIPT"

bash
