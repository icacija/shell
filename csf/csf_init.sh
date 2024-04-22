#! /bin/bash

#osnovno
sed -i 's/TESTING = "1"/TESTING = "0"/g' /etc/csf/csf.conf
sed -i 's/RESTRICT_SYSLOG = "0"/RESTRICT_SYSLOG = "3"/g' /etc/csf/csf.conf


#notifikacije
sed -i 's/PT_USERMEM = "512"/PT_USERMEM = "0"/g' /etc/csf/csf.conf
sed -i 's/PT_USERTIME = "1800"/PT_USERTIME = "0"/g' /etc/csf/csf.conf
sed -i 's/LF_INTEGRITY = "3600"/LF_INTEGRITY = "3600"/g' /etc/csf/csf.conf
sed -i 's/PT_LIMIT = "60"/PT_LIMIT = "60"/g' /etc/csf/csf.conf
sed -i 's/LF_QUEUE_ALERT = "2000"/LF_QUEUE_ALERT = "0"/g' /etc/csf/csf.conf
sed -i 's/PT_USERPROC = "10"/PT_USERPROC = "10"/g' /etc/csf/csf.conf

#email
sed -i 's/LF_EMAIL_ALERT = "1"/LF_EMAIL_ALERT = "0"/g' /etc/csf/csf.conf
sed -i 's/LF_PERMBLOCK_ALERT = "1"/LF_PERMBLOCK_ALERT = "0"/g' /etc/csf/csf.conf
sed -i 's/LF_NETBLOCK_ALERT = "1"/LF_NETBLOCK_ALERT = "0"/g' /etc/csf/csf.conf
sed -i 's/LF_DISTFTP_ALERT = "1"/LF_DISTFTP_ALERT = "0"/g' /etc/csf/csf.conf
sed -i 's/LF_DISTSMTP_ALERT = "1"/LF_DISTSMTP_ALERT = "0"/g' /etc/csf/csf.conf
sed -i 's/LT_EMAIL_ALERT = "1"/LT_EMAIL_ALERT = "0"/g' /etc/csf/csf.conf
sed -i 's/CT_EMAIL_ALERT = "1"/CT_EMAIL_ALERT = "0"/g' /etc/csf/csf.conf

# restart
systemctl restart csf
