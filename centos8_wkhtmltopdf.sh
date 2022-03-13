# /bin/bash
yum install xorg-x11-fonts-Type1 xorg-x11-fonts-75dpi -y
wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox-0.12.6-1.centos8.x86_64.rpm
rpm -i wkhtmltox-0.12.6-1.centos8.x86_64.rpm
echo -e "Installation done \nTesting:"
wkhtmltopdf https://google.hr google.pdf
echo -e "All done - cleaning \nIvan je najbolji "
rm -rf wkhtmltox-0.12.6-1.centos8.x86_64.rpm
rm -rf centos8_wkhtmltopdf.sh

