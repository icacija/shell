# /bin/bash

echo -e "Install java"
dnf install java-11-openjdk-devel -y

echo -e "Import RPM"
rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch -y

touch /etc/yum.repos.d/elasticsearch.repo

echo -e "Repo"
echo "[elasticsearch-8.x]" >> /etc/yum.repos.d/elasticsearch.repo
echo "name=Elasticsearch repository for 8.x packages" >> /etc/yum.repos.d/elasticsearch.repo
echo "baseurl=https://artifacts.elastic.co/packages/8.x/yum" >> /etc/yum.repos.d/elasticsearch.repo
echo "gpgcheck=1" >> /etc/yum.repos.d/elasticsearch.repo
echo "gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch" >> /etc/yum.repos.d/elasticsearch.repo
echo "autorefresh=1" >> /etc/yum.repos.d/elasticsearch.repo
echo "type=rpm-md" >> /etc/yum.repos.d/elasticsearch.repo

dnf install elasticsearch -y

systemctl start elasticsearch
systemctl enable elasticsearch

echo -e "config variables"
echo "transport.host: localhost" >> /etc/elasticsearch/elasticsearch.yml
echo "transport.tcp.port: 9300" >> /etc/elasticsearch/elasticsearch.yml
echo "http.port: 9200" >> /etc/elasticsearch/elasticsearch.yml
echo "network.host: 0.0.0.0" >> /etc/elasticsearch/elasticsearch.yml

echo -e "and restart elasticsearch"
systemctl restart elasticsearch

echo -e "all_done!"
