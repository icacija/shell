# /bin/bash

#Get script path
SCRIPT=$(readlink -f "$0")

wget -O cse_install.sh https://raw.githubusercontent.com/icacija/shell/main/cpanel/cse_install.sh
bash cse_install.sh && rm -f cse_install.sh
wget http://repo.nixpal.com/el8/nixpal-el8-1.1-1.el8.x86_64.rpm
yum localinstall nixpal-el8-1.1-1.el8.x86_64.rpm
yum clean all
yum install zcloudagent -y
echo -e "CSE i Zonecloud instalirani \nPotrebna daljna konfiguracija"

echo -e "Clean up"
rm -rf "$SCRIPT"
