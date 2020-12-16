#!/bin/bash

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
  restartBigBlueButton
  writeEnableRequest

  echo "  Finished graceful restart!"
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
