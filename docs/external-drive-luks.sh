sudo cryptsetup luksOpen /dev/sdc5 ext-luks
sudo vgchange -a y /dev/elementary-vg
sudo mount /dev/mapper/elementary--vg-root /mnt/extdrive

sudo umount /dev/mapper/elementary--vg-root /mnt/extdrive
sudo vgchange -a n /dev/elementary-vg
sudo cryptsetup luksClose ext-luks