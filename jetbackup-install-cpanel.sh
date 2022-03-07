# /bin.sh
# From https://docs.jetbackup.com/v5.1/adminpanel/generalInformation.html
yum install http://repo.jetlicense.com/centOS/jetapps-repo-latest.rpm
yum clean all --enablerepo=jetapps*
yum install jetapps --disablerepo=* --enablerepo=jetapps
jetapps --install jetbackup5-cpanel stable
echo -e "\aAll done"
