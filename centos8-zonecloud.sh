# /bin/bash
wget https://raw.githubusercontent.com/icacija/shell/main/cpanel-cse.sh
bash cpanel-cse.sh
wget http://repo.nixpal.com/el8/nixpal-el8-1.1-1.el8.x86_64.rpm
yum localinstall nixpal-el8-1.1-1.el8.x86_64.rpm
yum clean all
yum install zcloudagent -y
echo -e "CSE i Zonecloud instalirani \nPotrebna daljna konfiguracija"
