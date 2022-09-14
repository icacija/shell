# /bin/bash
cd /usr/local/directadmin/custombuild
./build update
./build set webserver litespeed
./build litespeed
./build rewrite_confs
