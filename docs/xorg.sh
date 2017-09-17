#!/bin/sh

# ------------------------------
# PART 2: XORG
# ------------------------------

# xorg: xorg-fonts xorg-server xorg-apps xorg-input-drivers xorg-video-drivers
xbps-install xorg-minimal xf86-video-intel xf86-video-amdgpu #xf86-video-ati # xorg-server xauth xinit xf86-input-evdev
xbps-install xorg-fonts xorg-apps xclip xdo xwininfo xorg-input-drivers ttf-ubuntu-font-family font-awesome
# Only in VBox-Install: xbps-install virtualbox-ose-guest
xbps-install wmutils sxhkd
#xbps-install howm
xbps-install dbus dbus-x11 libnotify 
xbps-install xrandr compton 
xbps-install st feh dmenu dunst lemonbar-xft maim ffmpeg slock

# xbps-install catalyst

vi /etc/X11/xorg.conf.d/20-keyboard.conf
Section "InputClass"
	Identifier "keyboard"
	MatchIsKeyboard "yes"
	Option "XkbLayout" "de"
	Option "XkbVariant" "nodeadkeys"
EndSection

mkdir ~/app/cnf/sxhkd

cat <<EOT >> ~/app/cnf/sxhkd/sxhkd 
super + Return
  xst

super + period
  dm-fm

super + {_,shift + }w
  bspc node -{c,k}

super + Escape
  pkill -USR1 -x sxhkd

super + alt + Escape
  bspc quit && kill $(pgrep stp)
EOT

cat <<EOT >> ~/app/cnf/bspwm/bspwmrc
#!/bin/sh
bspc monitor -d 1 2 3 4 5
EOT

xbps-install glxinfo

xrandr --listproviders

xrandr --setprovideroffloadsink 0f3f 0x66

lspci | grep -i -E '3d|display|vga'

DRI_PRIME=1 glxinfo | grep 'OpenGL'

cat <<EOT > /etc/modprobe.d/radeon.conf
blacklist radeon
EOT

cat <<EOT > /etc/X11/xorg.conf.d/30-amdgpu.conf
Section "Device"
  Identifier "AMD"
  Driver "amdgpu"
    Option "DRI" "3"
    Option "TearFree" "on"
EndSection
EOT

cat <<EOT > /etc/X11/xorg.conf.d/30-intel.conf
Section "Device"
  Identifier "intel"
  Driver "intel"
  Option "AccelMethod" "sna"
  Option "DRI" "3"
  BusID  "PCI:0:2:0"
EndSection
EOT

# BIOS -> 

# vdpauinfo

# https://www2.ati.com/drivers/linux/rhel7/amdgpu-pro-17.10-414273.tar.xz

#cat <<EOT > /etc/X11/xorg.conf.d/30-amdgpu.conf
#Section "Device"
#    Identifier "Radeon"
#    Driver "radeon"
#EndSection
#EOT

#https://bbs.archlinux.org/viewtopic.php?pid=1622419#p1622419
#radeon.runpm=0

# [AMD/ATI] Topaz XT [Radeon R7 M260/M265 / M340/M360 / M440/M445] [1002:6900] (rev c3)

# AMD Topaz XT R7 M445