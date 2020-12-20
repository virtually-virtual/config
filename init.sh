# Dynamic variables
PUBLIC_IP=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)
PRIVATE_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)

# IP Address and Hostname configuration

# HTML5 Addresses
yq w -i $HTML5_CONFIG public.kurento.wsUrl wss://dev.us-rooms.clickto.camp/bbb-webrtc-sfu
yq w -i $KURENTO_CONF kurento[0].ip "$PUBLIC_IP"
yq w -i $KURENTO_CONF freeswitch.ip "$PUBLIC_IP"
yq w -i $KURENTO_CONF freeswitch.sip_ip "$PRIVATE_IP"
yq w -i $KURENTO_CONF localIpAddress "$PRIVATE_IP"
# Properties
sed -i 's|bigbluebutton.web.serverURL=.*|bigbluebutton.web.serverURL=https://$FQDN|g' "$BBB_PROPERTIES"
sed -i "s/bbb\.sip\.app\.ip=.*/bbb\.sip\.app.ip=$PRIVATE_IP/g" /usr/share/red5/webapps/sip/WEB-INF/bigbluebutton-sip.properties
sed -i "s/freeswitch\.ip=.*/freeswitch\.ip=$PRIVATE_IP/g" /usr/share/red5/webapps/sip/WEB-INF/bigbluebutton-sip.properties
# Nginx address
sed -i "s/proxy_pass .*/proxy_pass https:\/\/$PUBLIC_IP:7443;/g" /etc/bigbluebutton/nginx/sip.nginx
sed -i "s/SERVERNAME_PLACEHOLDER/$FQDN/g" /etc/nginx/sites-available/bigbluebutton

# Freeswitch addresses
xmlstarlet edit --inplace --update '//X-PRE-PROCESS[@cmd="set" and starts-with(@data, "external_rtp_ip=")]/@data' --value "external_rtp_ip=$PUBLIC_IP" /opt/freeswitch/etc/freeswitch/vars.xml
xmlstarlet edit --inplace --update '//X-PRE-PROCESS[@cmd="set" and starts-with(@data, "external_sip_ip=")]/@data' --value "external_sip_ip=$PUBLIC_IP" /opt/freeswitch/etc/freeswitch/vars.xml
xmlstarlet edit --inplace --update '//X-PRE-PROCESS[@cmd="set" and starts-with(@data, "local_ip_v4=")]/@data' --value "local_ip_v4=$PRIVATE_IP" /opt/freeswitch/etc/freeswitch/vars.xml
xmlstarlet edit --inplace --update '//param[@name="wss-binding"]/@value' --value "$PUBLIC_IP:7443" /opt/freeswitch/conf/sip_profiles/external.xml
