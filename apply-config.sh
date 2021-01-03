#!/bin/bash

# Pull in the helper functions for configuring BigBlueButton
source /etc/bigbluebutton/bbb-conf/apply-lib.sh

# The locations of config files
KURENTO_CONF="/usr/local/bigbluebutton/bbb-webrtc-sfu/config/default.yml"
BBB_PROPERTIES="/usr/share/bbb-web/WEB-INF/classes/bigbluebutton.properties"
FREESWITCH_CONF="/opt/freeswitch/etc/freeswitch/autoload_configs/conference.conf.xml"
HTML5_CONFIG="/usr/share/meteor/bundle/programs/server/assets/app/config/settings.yml"




# Remove sounds
sed -i 's/^      <param name="muted-sound" value="conference\/conf-muted\.wav"\/>/<!--      <param name="muted-sound" value="conference\/conf-muted\.wav"\/> -->/g' $FREESWITCH_CONF
sed -i 's/^      <param name="unmuted-sound" value="conference\/conf-unmuted\.wav"\/>/<!--      <param name="unmuted-sound" value="conference\/conf-unmuted\.wav"\/> -->/g'  $FREESWITCH_CONF
sed -i 's/^      <param name="alone-sound" value="conference\/conf-alone\.wav"\/>/<!--      <param name="alone-sound" value="conference\/conf-alone\.wav"\/> -->/g'  $FREESWITCH_CONF



echo "  - Setting HTML5 Client"
yq w -i $HTML5_CONFIG public.app.clientTitle "Clickto"
yq w -i $HTML5_CONFIG public.app.appName "Clickto HTML5 Client"
yq w -i $HTML5_CONFIG public.app.helpLink "https://help.clickto.camp/"
yq w -i $HTML5_CONFIG public.app.copyright "©2020 Clickto LTD"

# Set Framerate and Resolution to high values - it will be throttled through bitrate
#yq w -i $HTML5_CONFIG public.kurento.screenshare.constraints.video.frameRate.ideal 5
#yq w -i $HTML5_CONFIG public.kurento.screenshare.constraints.video.frameRate.max 15
#yq w -i $HTML5_CONFIG public.kurento.screenshare.constraints.video.width.max 2560
#yq w -i $HTML5_CONFIG public.kurento.screenshare.constraints.video.height.max 1440
# Enable option to share screen with audio in supported browsers
yq w -i $HTML5_CONFIG public.kurento.screenshare.constraints.audio true
yq w -i $HTML5_CONFIG public.app.skipCheck true
yq w -i $HTML5_CONFIG public.app.forceListenOnly true
yq w -i $HTML5_CONFIG public.app.listenOnlyMode false
 
 
 
echo "  - Setting camera defaults"
yq w -i $HTML5_CONFIG public.kurento.cameraProfiles.[0].id minimal
yq w -i $HTML5_CONFIG public.kurento.cameraProfiles.[0].name "Minimal"
yq w -i $HTML5_CONFIG public.kurento.cameraProfiles.[0].default false
yq w -i $HTML5_CONFIG public.kurento.cameraProfiles.[0].bitrate 50
yq w -i $HTML5_CONFIG public.kurento.cameraProfiles.[0].hidden true
yq w -i $HTML5_CONFIG public.kurento.cameraProfiles.[0].constraints.video.framerate 3

yq w -i $HTML5_CONFIG public.kurento.cameraProfiles.[1].id niedrig
yq w -i $HTML5_CONFIG public.kurento.cameraProfiles.[1].name "Niedrig"
yq w -i $HTML5_CONFIG public.kurento.cameraProfiles.[1].default false
yq w -i $HTML5_CONFIG public.kurento.cameraProfiles.[1].bitrate 50
yq w -i $HTML5_CONFIG public.kurento.cameraProfiles.[1].hidden true
yq w -i $HTML5_CONFIG public.kurento.cameraProfiles.[1].constraints.video.framerate 3

yq w -i $HTML5_CONFIG public.kurento.cameraProfiles.[2].id mittel
yq w -i $HTML5_CONFIG public.kurento.cameraProfiles.[2].name "High"
yq w -i $HTML5_CONFIG public.kurento.cameraProfiles.[2].default true
yq w -i $HTML5_CONFIG public.kurento.cameraProfiles.[2].bitrate 50
yq w -i $HTML5_CONFIG public.kurento.cameraProfiles.[2].hidden false
yq w -i $HTML5_CONFIG public.kurento.cameraProfiles.[2].constraints.video.framerate 3

yq w -i $HTML5_CONFIG public.kurento.cameraProfiles.[3].id hoch
yq w -i $HTML5_CONFIG public.kurento.cameraProfiles.[3].name "Hoch"
yq w -i $HTML5_CONFIG public.kurento.cameraProfiles.[3].default false
yq w -i $HTML5_CONFIG public.kurento.cameraProfiles.[3].bitrate 50
yq w -i $HTML5_CONFIG public.kurento.cameraProfiles.[3].hidden true
yq w -i $HTML5_CONFIG public.kurento.cameraProfiles.[3].constraints.video.framerate 3

yq w -i $HTML5_CONFIG public.kurento.cameraProfiles.[4].id maximal
yq w -i $HTML5_CONFIG public.kurento.cameraProfiles.[4].name "Maximal"
yq w -i $HTML5_CONFIG public.kurento.cameraProfiles.[4].default false
yq w -i $HTML5_CONFIG public.kurento.cameraProfiles.[4].bitrate 50
yq w -i $HTML5_CONFIG public.kurento.cameraProfiles.[4].hidden true
yq w -i $HTML5_CONFIG public.kurento.cameraProfiles.[4].constraints.video.framerate 3

#echo "  - Setting camera thresholds"
#yq d -i $HTML5_CONFIG public.kurento.cameraQualityThresholds
#yq w -i $HTML5_CONFIG public.kurento.cameraQualityThresholds.enabled false
#
#yq w -i $HTML5_CONFIG public.kurento.cameraQualityThresholds.thresholds.[0].threshold 1
#yq w -i $HTML5_CONFIG public.kurento.cameraQualityThresholds.thresholds.[0].profile high

#yq w -i $HTML5_CONFIG public.kurento.cameraQualityThresholds.thresholds.[1].threshold 2
#yq w -i $HTML5_CONFIG public.kurento.cameraQualityThresholds.thresholds.[1].profile medi#um

#yq w -i $HTML5_CONFIG public.kurento.cameraQualityThresholds.thresholds.[2].threshold 3
#yq w -i $HTML5_CONFIG public.kurento.cameraQualityThresholds.thresholds.[2].profile low

#yq w -i $HTML5_CONFIG public.kurento.cameraQualityThresholds.thresholds.[3].threshold 4
#yq w -i $HTML5_CONFIG public.kurento.cameraQualityThresholds.thresholds.[3].profile minimal

echo "  - Setting camera pagination"
yq w -i $HTML5_CONFIG public.kurento.pagination.enabled true
yq w -i $HTML5_CONFIG public.kurento.pagination.desktopPageSizes.moderator 8
yq w -i $HTML5_CONFIG public.kurento.pagination.desktopPageSizes.viewer 8
yq w -i $HTML5_CONFIG public.kurento.pagination.mobilePageSizes.moderator 4
yq w -i $HTML5_CONFIG public.kurento.pagination.mobilePageSizes.viewer 4

#echo " - Setting Screenshare and Video Constraints"
#yq w -i $KURENTO_CONF conference-media-specs.H264.tias_content 1500000
#yq w -i $KURENTO_CONF conference-media-specs.H264.as_content 1500
#yq w -i $KURENTO_CONF conference-media-specs.VP8.tias_content 1500000
#yq w -i $KURENTO_CONF conference-media-specs.VP8.as_content 1500

#echo " - Setting BigBlueButton-Options"
#sed -i 's|beans.presentationService.defaultUploadedPresentation=.*|beans.presentationService.defaultUploadedPresentation=${bigbluebutton.web.serverURL}/default.pdf|g' "$BBB_PROPERTIES"

#sed -i 's|maxFileSizeUpload=.*|maxFileSizeUpload=30000000|g' "$BBB_PROPERTIES"
#sed -i 's|defaultWelcomeMessage=.*|defaultWelcomeMessage=Welcome|g' "$BBB_PROPERTIES"
#sed -i 's|defaultWelcomeMessageFooter=.*|defaultWelcomeMessageFooter=Welcome|g' "$BBB_PROPERTIES"
#sed -i 's|allowModsToUnmuteUsers=.*|allowModsToUnmuteUsers=false|g' "$BBB_PROPERTIES"
#sed -i 's|meetingExpireIfNoUserJoinedInMinutes=.*|meetingExpireIfNoUserJoinedInMinutes=5|g' "$BBB_PROPERTIES"
#sed -i 's|meetingExpireWhenLastUserLeftInMinutes=.*|meetingExpireWhenLastUserLeftInMinutes=5|g' "$BBB_PROPERTIES"
#sed -i 's|userInactivityInspectTimerInMinutes=.*|userInactivityInspectTimerInMinutes=60|g' "$BBB_PROPERTIES"
#sed -i 's|userInactivityThresholdInMinutes=.*|userInactivityThresholdInMinutes=240|g' "$BBB_PROPERTIES"
sed -i 's|muteOnStart=.*|muteOnStart=true|g' "$BBB_PROPERTIES"


echo "  - Setting room restrictions"
sed -i 's|lockSettingsDisableCam=.*|lockSettingsDisableCam=false|g' "$BBB_PROPERTIES"
sed -i 's|lockSettingsDisablePrivateChat=.*|lockSettingsDisablePrivateChat=true|g' "$BBB_PROPERTIES"
sed -i 's|lockSettingsDisablePublicChat=.*|lockSettingsDisablePublicChat=false|g' "$BBB_PROPERTIES"
sed -i 's|lockSettingsDisableNote=.*|lockSettingsDisableNote=true|g' "$BBB_PROPERTIES"
sed -i 's|lockSettingsHideUserList=.*|lockSettingsHideUserList=false|g' "$BBB_PROPERTIES"
sed -i 's|lockSettingsDisableMic=.*|lockSettingsDisableMic=false|g' "$BBB_PROPERTIES"

echo " - Dont allow duplicate UserExt"
sed -i 's|allowDuplicateExtUserid=.*|allowDuplicateExtUserid=false|g' "$BBB_PROPERTIES"


sed -i 's|disableRecordingDefault=.*|disableRecordingDefault=false|g' "$BBB_PROPERTIES"
sed -i 's|allowStartStopRecording=.*|allowStartStopRecording=true|g' "$BBB_PROPERTIES"
sed -i 's|keepEvents=.*|keepEvents=true|g' "$BBB_PROPERTIES"

#yq m -x --overwrite -i /usr/share/meteor/bundle/programs/server/assets/app/config/settings.yml /tmp/settings.yml

#echo " - Enable multiple Kurento proccesses"
#enableMultipleKurentos



