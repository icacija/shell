# /bin/bash
cd /usr/local/directadmin/custombuild
./build update
./build set webserver openlitespeed
./build openlitespeed
./build rewrite_confs
