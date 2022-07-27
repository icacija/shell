# /bin/bash
cd /usr/local/directadmin/custombuild
./build update
./build set webserver litespeed
./build set php1_mode lsphp
./build set php2_mode lsphp
./build set php3_mode lsphp
./build set php4_mode lsphp
./build litespeed
./build php n
./build rewrite_confs
