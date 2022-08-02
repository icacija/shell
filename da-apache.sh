# /bin/bash
cd /usr/local/directadmin/custombuild
./build update
./build set webserver apache
./build set php1_mode php-fpm
./build apache
./build php n
./build rewrite_confs
