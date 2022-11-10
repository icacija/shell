# /bin/bash
tar -czf /backup/var_named.tar.gz /var/named
mkdir /backup/named_unwanted_zones
cut -d ':' -f1 /etc/userdomains >> /etc/managed_domains
for domains in $(ls /var/named/*.db | cut -d '/' -f 4 | awk 'BEGIN{FS=OFS="."}{NF--; print}' ); do if ! (grep -q $domains /etc/managed_domains); then mv /var/named/${domains}.db /backup/named_unwanted_zones/${domains}.db; fi done
/scripts/rebuilddnsconfig
echo -e "all done"
rm -rf cpanel_rm_cluster_zones.sh
