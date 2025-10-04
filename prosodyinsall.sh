#!/bin/bash
# By Sameer
#set -e
set -x
### In this 0.0.0.0 is just the dummy ip #####
# ===== Variables =====
ROOT_DIR="/root/migration/"
CONF_DIR="/etc/prosody"
PROSODY_CONF="${CONF_DIR}/prosody.cfg.lua"
DOMAIN=$(licenseDetails | grep global | awk '{print $3}')
DOMAIN_CONF="${CONF_DIR}/conf.d/${DOMAIN}.cfg.lua"
DBPASS=$(grep pass /opt/einteract/conf/einteract.ini | head -1 | awk '{print $3}')
CHAT_CONFIG_JSON="/opt/orion-data/data/settings/modules/ChatWebclient.config.json"
PROSODY_RPM_DIR="${ROOT_DIR}/prosody"
PROSODY_MODULES="/usr/lib64/prosody/modules"
CUSTOM_PLUGINS="/var/lib/prosody/custom_plugins/share/lua/5.4"
CRON_SCRIPT="/opt/einteract/cron/auto_users.pl"
CRON_LOG_DIR="/tmp/cronlogs"
NGINX_CERT="/etc/nginx/ssl/nginx.crt"
NGINX_KEY="/etc/nginx/ssl/nginx.key"
CONFIG_ARCHIVE="${ROOT_DIR}/prosody_configs.tgz"
PROSODY_LUA="${ROOT_DIR}/prosody.lua"
DOMAIN_CFG="${ROOT_DIR}/domain.cfg.lua"
BACKUPFILE="/opt/einteract/utils/backupfile"
PROSODYDUMP="${ROOT_DIR}/prosody_dump.sql"

# ===== Sanity Checks =====
echo "Make sure prosodynew.tgz, prosody_configs.tgz and prosody_dump.sql exist in ${ROOT_DIR}"
sleep 5

cd "$ROOT_DIR"
echo "Checking connectivity 0.0.0.0"
timeout 5 bash -c "</dev/tcp/0.0.0.0/443" 2>/dev/null
RET=$?
if [ "$RET" -eq 0 ]; then
    echo "Internet OK. Downloading required files..."
    wget http://0.0.0.0/ncis_dev/aurora9/prosody_configs.tgz  --user sameer --password 'cxz!&#$f@' || echo "prosody tar download failed."
    wget http://0.0.0.0/ncis_dev/aurora9/prosodynew.tgz  --user sameer --password 'cxz!&#$f@' || echo "prosody tar download failed."
    wget http://0.0.0.0/ncis_dev/aurora9/prosody_dump.sql --user sameer --password 'cxz!&#$f@' || echo "prosody dump download failed."
else
    echo "Cannot connect to 0.0.0.0. Using local copies in /root/migration/..."
fi

# ===== Extract Prosody Tarball =====
if [ -f "${ROOT_DIR}/prosodynew.tgz" ]; then
    cd "${ROOT_DIR}" || exit
    tar -xvf prosodynew.tgz
else
    echo "Prosody tar is not present under ${ROOT_DIR}. Please copy the tar and re-run the script."
    exit 1
fi

# ===== Extract Prosody Config Files from Archive =====
if [ -f "$CONFIG_ARCHIVE" ]; then
    echo "Extracting $CONFIG_ARCHIVE..."
    tar -xvzf "$CONFIG_ARCHIVE" -C "$ROOT_DIR"
else
    echo "Archive $CONFIG_ARCHIVE not found. Please place it in $ROOT_DIR and retry."
    exit 1
fi

if [ -f "$PROSODY_LUA" ] && [ -f "$DOMAIN_CFG" ]; then
    echo "Applying configuration files..."
    cat "$PROSODY_LUA" > "$PROSODY_CONF"
    cat "$DOMAIN_CFG" > "$DOMAIN_CONF"


    sed -i "s/demoganesh.nstest.com/${DOMAIN}/g" "$DOMAIN_CONF"
else
    echo "One of files (prosody.lua, domain.cfg.lua) missing after extraction."
    exit 1
fi


# ===== Prosody Chat Config =====
echo "===== Starting prosody chat configuration ====="
sleep 2
sed -i 's/\btrue\b/false/' "${CHAT_CONFIG_JSON}"

# ===== RPM Install =====
for pkg in lua-cyrussasl-1.1.0-12.el9.x86_64 lua-dbi-0.7.3-1.el9.x86_64; do
    rpm -q "$pkg" || yum install -y "${PROSODY_RPM_DIR}/${pkg}.rpm"
done

# ===== Restart & Module Setup =====
systemctl restart prosody

cp -pav "${PROSODY_RPM_DIR}/auto_users.pl" "${CRON_SCRIPT}"
chmod 777 "${CRON_SCRIPT}"

"$BACKUPFILE" "${PROSODY_MODULES}/mod_storage_sql.lua"
cat "${PROSODY_RPM_DIR}/mod_storage_sql.lua" > "${PROSODY_MODULES}/mod_storage_sql.lua"

cp "${PROSODY_RPM_DIR}/mod_list.lua" "${PROSODY_MODULES}/"
cp "${PROSODY_RPM_DIR}/mod_http_upload.lua" "${CUSTOM_PLUGINS}/"

"$BACKUPFILE" "${CUSTOM_PLUGINS}/mod_auth_cyrus.lua"
cat "${PROSODY_RPM_DIR}/mod_auth_cyrus.lua" > "${CUSTOM_PLUGINS}/mod_auth_cyrus.lua"

# ===== Cron Setup =====
mkdir -p "${CRON_LOG_DIR}"
(crontab -l 2>/dev/null; echo "0 */5 * * * ${CRON_SCRIPT} >> ${CRON_LOG_DIR}/autousers_\$(date +\%F).log 2>&1") | crontab -

# ===== Disable Default Configs =====
cd "${CONF_DIR}/conf.d" || exit
[ -f exampledomain.com.cfg.lua ] && mv exampledomain.com.cfg.lua exampledomain.com.cfg.lua_old
[ -f example.com.cfg.lua ] && mv example.com.cfg.lua example.com.cfg.lua_old
[ -f localhost.cfg.lua ] && mv localhost.cfg.lua localhost.cfg.lua_old

# ===== Update Password and Upgrade Storage =====
echo "Updating password in prosody configuration"
sed -i "s|\"wrdh7x3qg5i\"|\"${DBPASS}\"|g" "${PROSODY_CONF}"

chmod 777 "${NGINX_CERT}"
chmod 777 "${NGINX_KEY}"

"${CRON_SCRIPT}"
systemctl restart prosody

echo "====Restoring dump into prosody===="
if [ -f "$PROSODYDUMP" ];then 
mysql -u root -p"$DBPASS@123#" < "$PROSODYDUMP"
echo "Upgrading prosody storage"
yes | prosodyctl mod_storage_sql upgrade
if [ $? -eq 0 ]; then
    echo "Upgraded storage"
    systemctl restart prosody
else
    echo "Issue while upgrading storage"
fi
else
echo "Dump not found.. skipping Dump restoration"

systemctl restart prosody

# ===== Final Notes =====
echo "====== Prosody installation and configuration completed ========"
sleep 2
echo " Please update your all-bundle SSL certificate & key:"
echo "   - Cert: ${NGINX_CERT}"
echo "   - Key : ${NGINX_KEY}"
echo " Ensure the domain '${DOMAIN}' is publicly resolvable via DNS if users are external."
echo " Check /etc/hosts (if local mapping is needed):"
echo "   xx.xx.xx.xx ${DOMAIN}"
echo " For any issues, check: /var/log/prosody/prosody.err"

