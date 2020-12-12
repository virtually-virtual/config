#!/bin/bash

source /etc/bigbluebutton/bbb-conf/apply-lib.sh

# Remove sounds
sed -i '/alone-sound/d' /opt/freeswitch/etc/freeswitch/autoload_configs/conference.conf.xml
sed -i '/unmuted-sound/d' /opt/freeswitch/etc/freeswitch/autoload_configs/conference.conf.xml
sed -i '/muted-sound/d' /opt/freeswitch/etc/freeswitch/autoload_configs/conference.conf.xml

# Default settings for participants
sed -i 's/muteOnStart=.*/muteOnStart=true/g' /usr/share/bbb-web/WEB-INF/classes/bigbluebutton.properties
sed -i 's/disableRecordingDefault=.*/disableRecordingDefault=false/g' /usr/share/bbb-web/WEB-INF/classes/bigbluebutton.properties
sed -i 's/autoStartRecording=.*/autoStartRecording=false/g' /usr/share/bbb-web/WEB-INF/classes/bigbluebutton.properties
sed -i 's/allowStartStopRecording=.*/allowStartStopRecording=true/g' /usr/share/bbb-web/WEB-INF/classes/bigbluebutton.properties
sed -i 's/lockSettingsDisableCam=.*/lockSettingsDisableCam=false/g' /usr/share/bbb-web/WEB-INF/classes/bigbluebutton.properties
sed -i 's/lockSettingsDisableMic=.*/muteOnStart=false/g' /usr/share/bbb-web/WEB-INF/classes/bigbluebutton.properties
sed -i 's/lockSettingsDisablePublicChat=.*/lockSettingsDisablePublicChat=false/g' /usr/share/bbb-web/WEB-INF/classes/bigbluebutton.properties
sed -i 's/lockSettingsDisablePrivateChat=.*/lockSettingsDisablePrivateChat=true/g' /usr/share/bbb-web/WEB-INF/classes/bigbluebutton.properties
sed -i 's/lockSettingsDisableNote==.*/lockSettingsDisableNote=true/g' /usr/share/bbb-web/WEB-INF/classes/bigbluebutton.properties
sed -i 's/lockSettingsHideUserList=.*/lockSettingsHideUserList=false/g' /usr/share/bbb-web/WEB-INF/classes/bigbluebutton.properties
sed -i 's/muteOnS=.*/muteOnStart=true/g' /usr/share/bbb-web/WEB-INF/classes/bigbluebutton.properties


sed -i 's/^<param name="comfort-noise" value=/<param name="comfort-noise" value="false"\/>/g' /opt/freeswitch/etc/freeswitch/autoload_configs/conference.conf.xml
sed -i 's/^<param name="energy-level" value=/<param name="energy-level" value="0"\/>/g' /opt/freeswitch/etc/freeswitch/autoload_configs/conference.conf.xml
