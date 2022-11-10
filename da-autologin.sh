# /bin/bash

#Get script path
SCRIPT=$(readlink -f "$0")

echo -e "PMA"

cd /usr/local/directadmin/
./directadmin set one_click_pma_login 1
service directadmin restart
cd custombuild
./build update
./build phpmyadmin

cd /usr/local/directadmin/custombuild
./build update
./build set phpmyadmin_public no
./build phpmyadmin

echo -e "Roundcube"

cd /usr/local/directadmin/
./directadmin set one_click_webmail_login 1
service directadmin restart
cd custombuild
./build update
./build dovecot_conf
./build exim_conf
./build roundcube

echo -e "Done"

echo -e "Clean up"
rm -rf "$SCRIPT"

bash
