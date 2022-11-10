# /bin/bash
cd /usr/src
rm -fv /usr/src/cse.tgz
wget https://download.configserver.com/cse.tgz
tar -xzf cse.tgz
cd cse
sh install.sh
rm -Rfv /usr/src/cse*
rm -Rfv cpanel-cse.sh
echo -e "All done - thx"
