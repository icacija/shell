# /bin/bash

echo -e "Disable selinux"
sudo sed -i 's/enforcing/disabled/g' /etc/selinux/config /etc/selinux/config
sudo sestatus

echo -e "Change SSH port to 9001"
echo "Port 9001" >> /etc/ssh/sshd_config

echo -e "Change root color"
bashrc='/etc/bashrc'
script64='IyBDb2xvcnMgaW4gVGVybWluYWwKaWYgWyAkVVNFUiA9IHJvb3QgXTsgdGhlbgogICAgICAgIFBTMT0nXFtcMDMzWzE7MzFtXF1bXHVAXGggXFddXCRcW1wwMzNbMG1cXSAnCmVsc2UKICAgICAgICBQUzE9J1xbXDAzM1swMTszMm1cXVx1QFxoXFtcMDMzWzAwbVxdIFxbXDAzM1swMTszNG1cXVxXXFtcMDMzWzAwbVxdXFtcMDMzWzE7MzJtXF1cJFxbXDAzM1ttXF0gJwpmaQo='
echo $script64 | base64 -d >> $bashrc

bash

echo -e "Change timezone to Europe/Zagreb"
timedatectl set-timezone Europe/Zagreb


echo -e "Done for now \nPlease reboot"

echo -e "clean-up"
rm -rf centos-inicial.sh
