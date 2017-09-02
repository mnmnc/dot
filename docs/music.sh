#!/bin/sh

xpbs-install mpd mpc

mkdir -p /data/share/{pls,sng}
chown mpd:mpd /data/share/{pls,sng}

# head -n 1 /proc/asound/card0/codec*
# cat /proc/asound/cards

cat >/etc/modprobe.d/alsa-base.conf<<EOF
options snd-hda-intel model=auto power_save=0 power_save_controller=N
EOF

cat >>/etc/mpd.conf<<EOF
music_directory "/data/share/sng"
playlist_directory "/data/share/pls"
audio_output {
  type                  "alsa"
  name                  "Sound Card"
}
EOF

cat >/etc/asound.conf<<EOF
defaults.pcm.!card PCH
defaults.pcm.!device 0
defaults.pcm.!ctl PCH
EOF

gpasswd -a mpd audio

ln -s /etc/sv/mpd /var/service