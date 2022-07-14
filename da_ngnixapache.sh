cd /usr/local/directadmin/custombuild
./build update
./build update_da
./build set webserver nginx_apache
./build set php1_mode php-fpm
./build nginx_apache
./build php n
./build rewrite_confs
