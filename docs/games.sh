#!/bin/sh

xbps-install hedgwars ImageMagick mercurial

xbps-install void-repo-multilib
xbps-install wine winetricks
xbps-install playonlinux

winetricks corefonts