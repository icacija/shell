# /bin.sh
# From https://docs.jetbackup.com/v5.2/adminpanel/generalInformation.html#installation-guide
bash <(curl -LSs http://repo.jetlicense.com/static/install)
jetapps --install jetbackup5-cpanel stable
echo -e "Cleaning time"
rm -rf jetbackup-install-cpanel.sh
echo -e "\aAll done"
