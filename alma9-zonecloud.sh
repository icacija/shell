# /bin/bash

#Get script path
SCRIPT=$(readlink -f "$0")

wget https://raw.githubusercontent.com/icacija/shell/main/cpanel-cse.sh
bash cpanel-cse.sh
wget https://repo.nixpal.com/el9/nixpal-el9-1.0-0.el9.x86_64.rpm
yum localinstall nixpal-el9-1.0-0.el9.x86_64.rpm
yum clean all
yum install zcloudagent -y
echo -e "CSE i Zonecloud instalirani \nPotrebna daljna konfiguracija"

echo -e "Clean up"
rm -rf "$SCRIPT"
