# /bin/bash

echo -e "update first"
apt-get update
apt-get upgrade -y

echo -e "install elastic"
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-7.x.list
sudo apt-get update && sudo apt-get install elasticsearch
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

