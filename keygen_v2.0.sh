#!/bin/bash

#Script generate the ED25519 keys in respective home folders.
#Script validate users from /etc/passwd & /home directory
#Script append the userid & key in /tmp/userkeys.csv
#Script do labelling for respective users key
#Usage sh keygen.sh
# 2018-09-10 / 1.0.0 / Rahul Kolan : Creation

FILENAME=/etc/passwd
date=$(date '+%F_%H:%M:%S')
#echo $FILENAME;
>/tmp/userkeys.csv
SKIPUSERS=['automate','sasauto','asbadmin']
while IFS=: read -a eachLine;do
  USER=${eachLine[0]}
  LABEL=${eachLine[4]}
  USERHOMEPATH=/home/$USER 
 
  if echo ${SKIPUSERS[@]} | grep -q -w "$USER"; then
   echo "USER $USER FOUND IN SKIPUSER,so ignoring"
  else
   if [ -d "$USERHOMEPATH" ]; then
      echo "user $USER exists in /home directory"
     #rm -f /home/$USER/.ssh/id_*
     rm -f /home/$USER/.ssh/id_ed25519*
     /bin/ssh-keygen -t ed25519 -N "" -f /home/$USER/.ssh/id_ed25519 -a 100 -C "$LABEL $date" 
     chown $USER:$USER /home/$USER/.ssh/id_ed25519
     chown $USER:$USER /home/$USER/.ssh/id_ed25519.pub
     USERSSHKEY=$(cat /home/$USER/.ssh/id_ed25519.pub)
     echo "$USER,$USERSSHKEY" >>/tmp/userkeys.csv
   fi
  fi

done < $FILENAME
