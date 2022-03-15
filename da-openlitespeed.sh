# /bin/sh
./build update
./build set webserver openlitespeed
./build set mod_ruid2 no
./build set php1_mode lsphp
./build openlitespeed
./build php n
./build rewrite_confs
