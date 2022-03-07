# /bin.sh
# From https://docs.jetbackup.com/v5.1/adminpanel/generalInformation.html
yum install http://repo.jetlicense.com/centOS/jetapps-repo-latest.rpm -y
yum clean all --enablerepo=jetapps*
yum install jetapps --disablerepo=* --enablerepo=jetapps -y
jetapps --install jetbackup5-cpanel stable -y
echo -e "Cleaning time"
rm -rf jetbackup-install-cpanel.sh
echo -e "\aAll done"
