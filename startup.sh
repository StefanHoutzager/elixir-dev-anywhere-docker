#!/bin/bash

# mkdir /var/run/sshd

# set the passwords for the user and the x11vnc session
# based on environment variables (if present), otherwise roll with
# the defaults from the Dockerfile build. 
#
# I'm clearing the environmental variables used for passwords after
# setting them because the presumption is users will only access this 
# container via a web browser referral from a seperately authenticated 
# page, so I don't want to leak password info via these variables

if [ ! -z $UBUNTUPASS ] 
then
  /bin/echo "ubuntu:$UBUNTUPASS" | /usr/sbin/chpasswd
  UBUNTUPASS=''
fi

if [ ! -z $VNCPASS ] 
then
  /usr/bin/x11vnc -storepasswd $VNCPASS  /home/root/.vnc/passwd 
  VNCPASS=''
fi

/usr/bin/supervisord -c /etc/supervisor/supervisord.conf

for f in /etc/startup.aux/*.sh
do
    . $f
done

#  ;while [ 1 ]; do
/bin/bash
#  done
