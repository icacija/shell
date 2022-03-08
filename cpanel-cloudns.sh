# /bin/bash
echo -e "Install CSE"
wget https://raw.githubusercontent.com/icacija/shell/main/cpanel-cse.sh
bash cpanel-cse.sh
echo -e "\Done"
echo -e "\Create /etc/fastserver"
mkdir /etc/fastserver
cd /etc/fastserver
wget https://raw.githubusercontent.com/ClouDNS/cloudns-api-bulk-updates/master/cpanel-slave-zones-add/cpanel-slave-zones-add.php
echo -e "Potrebno je rucno urediti ostalo"
