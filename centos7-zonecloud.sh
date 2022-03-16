# /bin/bash
wget http://repo.nixpal.com/el7/nixpal-el7-1.1-1.el7.x86_64.rpm
yum -y localinstall nixpal-el7-1.1-1.el7.x86_64.rpm 
yum clean all
yum install zcloudagent
