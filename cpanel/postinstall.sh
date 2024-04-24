# /bin/bash

#Get script path
SCRIPT=$(readlink -f "$0")

echo -e "CSF Install"

cd /usr/src
rm -fv csf.tgz
wget https://download.configserver.com/csf.tgz
tar -xzf csf.tgz
cd csf
sh install.sh

echo -e "CMQ Install"
cd /usr/src
rm -fv /usr/src/cmq.tgz
wget https://download.configserver.com/cmq.tgz
tar -xzf cmq.tgz
cd cmq
sh install.sh
rm -Rfv /usr/src/cmq*

echo -e "CSE Install"
cd /usr/src
rm -fv /usr/src/cse.tgz
wget https://download.configserver.com/cse.tgz
tar -xzf cse.tgz
cd cse
sh install.sh
rm -Rfv /usr/src/cse*

# CSF Conf
cd /root
wget https://raw.githubusercontent.com/icacija/shell/main/csf/csf_init.sh
bash csf_init.sh

echo -e "Clean up"
rm -rf "$SCRIPT"
