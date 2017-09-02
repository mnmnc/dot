#!/bin/sh

xbps-install rclone

# on server:
rclone config

# On windows machine:
# ./rclone.exe authorize "amazon cloud drive"

# rclone lsd <server>:

# mount on /data/acd


rclone mount ACD: ~/usr/acd &

