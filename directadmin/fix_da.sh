# can be one of: alpha, beta, current, stable or EOL channels: freebsd, rhel6, debian8, debian9
CHANNEL=current 

 # can be: linux_amd64, linux_arm64, freebsd_amd64
OS_SLUG=linux_amd64

# can be commit hash literal value if you want specific build to be installed
COMMIT=$(dig +short -t txt "$CHANNEL-version.directadmin.com" | sed 's|.*commit=\([0-9a-f]*\).*|\1|')

# creates download package name from the variables above
FILE="directadmin_${COMMIT}_${OS_SLUG}.tar.gz"

# downloads given directadmin build into /root dir
curl --location --progress-bar --connect-timeout 10 "https://download.directadmin.com/${FILE}" --output "/root/${FILE}"

# extracts downloaded package to /usr/local/directadmin
tar xzf "/root/${FILE}" -C /usr/local/directadmin  

# runs post-upgrade permission fix step
/usr/local/directadmin/directadmin permissions || true 

# runs other post upgrade fixes
/usr/local/directadmin/scripts/update.sh

# Restart DA
service directadmin restart
