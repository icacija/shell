# /bin/bash
wget -O cse_install.sh https://raw.githubusercontent.com/icacija/shell/main/cpanel/cse_install.sh
bash cse_install.sh && rm -f cse_install.sh
wget http://repo.nixpal.com/el7/nixpal-el7-1.1-1.el7.x86_64.rpm
yum -y localinstall nixpal-el7-1.1-1.el7.x86_64.rpm 
yum clean all
yum -y install zcloudagent 
echo -e "CSE i Zonecloud instalirani \nPotrebna daljna konfiguracija"
rm -rf centos7-zonecloud.sh
