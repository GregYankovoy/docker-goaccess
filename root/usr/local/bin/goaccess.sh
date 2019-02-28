#!/bin/sh

echo -e "Variables set:\\n\
PUID=${PUID}\\n\
PGID=${PGID}\\n"

# create necessary config dirs if not present
mkdir -p /config/html
mkdir -p /config/data
mkdir -p /config/log

# copy default goaccess config if not present
[ -f /config/goaccess.conf ] || cp /opt/goaccess.conf /config/goaccess.conf

# create an empty access.log file so goaccess does not crash if not exist
[ -f /config/log/access.log ] || touch /config/log/access.log

# make things easier on the users with access to the folders
chmod -R 777 /config

# ready to go
/sbin/tini -s -- nginx -c /opt/nginx.conf
/sbin/tini -s -- goaccess --no-global-config --config-file=/config/goaccess.conf