#!/bin/bash

BUCKET=

# The node id from this bbb instance as showed on the scalelite server
NODE_ID=01234567-89ab-cdef-0123-456789abcdef

# The user to connect to on the scalelite server
SSH_USER=scalelitecommander

# The hostname of the scalelite server
SSH_HOST=bbb.example.com

# The location to the private key on this bbb instance to use
SSH_KEY=/home/bigbluebutton/.ssh/scalelite

# The directory on the scalelite server where the command files should be placed
# CAUTION: trailing slash is mandatory!
COMMAND_DIR=/home/scalelitecommander/commands/

main()
{
  echo -n "[$(date)] "
  echo "Initiate graceful restart of bbb..."

  checkOpPending
  writeDisableRequest
  waitForDeactivation
  waitForMeetings
  waitArchiveRecordings
  checkRecordings
  echo "  Finished graceful restart!"
}

countRecordings(){
  kurentoWebcamFilesCount=$(ls -l //var/kurento/recordings | wc -l)
  kurentoScreenshareFilesCount=$(ls -l /var/kurento/screenshare | wc -l)
  freeswitchFilesCount=$(ls -l /var/freeswitch/meetings | wc -l)
  
  if [ $kurentoWebcamFilesCount -ge 0 ] || [ $kurentoScreenshareFilesCount -ge 0 ] || [ $freeswitchFilesCount -gt 0]; then
     UNPROCESSED_STATUS=1
  else
     UNPROCESSED_STATUS=0
  fi
  echo -n "$UNPROCESSED_STATUS"
}

waitForRecordings(){
  count=0
  status=$(countRecordings())
  echo -n "  - Waiting for recordings to render ..."
  
  while [[ $status -gt 0 ]]; do
    echo -n "."
    sleep 90
    count=$count + 1
    status=$(countRecordings())
    if [ $count -gt 20 ];then
       tar -czf $(hostname).tar.gz /var/freeswitch/meetings /var/kurento /var/bigbluebutton
       aws s3 cp $(hostname).tar.gz s3://render-server
       aws sns publish --topic-arn  arn:aws:sns:us-west-2:475610229463:RecordingStatus:0cbcd298-179d-4425-8a93-a08cbd2ec6ff --message "Archiving recordings too long!"
    fi
  done
  aws s3 cp $(hostname)-archive.tar.gz s3://render-server
}

checkOpPending()
{
  if ssh -i $SSH_KEY $SSH_USER@$SSH_HOST [[ -f $COMMAND_DIR$NODE_ID ]]; then
    echo "  Operation already pending. Abort."
    exit 1
  fi
}

writeDisableRequest()
{
  echo "  - Writing request to disable node..."
  ssh -i $SSH_KEY $SSH_USER@$SSH_HOST "echo \"disable\" > $COMMAND_DIR$NODE_ID"
}

waitForDeactivation()
{
  echo -n "  - Waiting for scalelite to disable node..."

  while [[ $(ssh -i $SSH_KEY $SSH_USER@$SSH_HOST cat $COMMAND_DIR$NODE_ID) == "disable" ]]; do
    echo -n "."
    sleep 90
  done

  echo

  if [[ $(ssh -i $SSH_KEY $SSH_USER@$SSH_HOST cat $COMMAND_DIR$NODE_ID) != "OK" ]]; then
    echo "  Could not disable node. Abort."
    exit 1
  fi
}

waitForMeetings()
{
  echo -n "  - Waiting for meetings to finish..."

  while [[ $(getNoOfMeetings) -gt 0 ]]; do
    echo -n "."
    sleep 90
  done

  echo
}

getNoOfMeetings()
{
  APICallName="getMeetings"
  APIQueryString=""

  X=$( bbb-conf --secret | fgrep URL: )
  APIEndPoint=${X##* }
  Y=$( bbb-conf --secret | fgrep Secret: )
  Secret=${Y##* }
  S=$APICallName$APIQueryString$Secret
  Checksum=$( echo -n $S | sha1sum | cut -f 1 -d ' ' )
  if [[ "$APIQueryString" == "" ]]
  then
          URL="${APIEndPoint}api/$APICallName?checksum=$Checksum"
  else
          URL="${APIEndPoint}api/$APICallName?$APIQueryString&checksum=$Checksum"
  fi
  wget -q -O - "$URL" | grep -o '<meetingID>' | wc -w
}

restartBigBlueButton()
{
  bbb-conf --restart
}

writeEnableRequest()
{
  echo "  - Writing request to enable node..."
  ssh -i $SSH_KEY $SSH_USER@$SSH_HOST "echo \"enable\" > $COMMAND_DIR$NODE_ID"
}

main
