#!/bin/sh

# ------------------------------
# FONTS
# ------------------------------
xbps-install font-hack-ttf
echo '*.font: xft:Hack:pixelsize=15' >> ~/.Xresources