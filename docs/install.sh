#!/bin/sh

# ------------------------------
# PART 1: PARTITIONS, LUKS + LVM
# ------------------------------

bash # Continue

loadkeys de-latin1-nodeadkeys # Continue

sfdisk /dev/hda <<EOF
,1G,,*
,
EOF

mkfs.ext4 -L boot /dev/sda1

cryptsetup --cipher aes-xts-plain64 --key-size 512 --hash sha512 --iter-time 1000 --use-urandom --verify-passphrase luksFormat /dev/sda2
cryptsetup luksOpen /dev/sda2 luks # Continue

pvcreate /dev/mapper/luks
vgcreate lvm /dev/mapper/luks

lvcreate -L 10GB -n void lvm
lvcreate -L 10GB -n copy lvm
lvcreate -L 4GB -n swap lvm
lvcreate -l 100%FREE -n data lvm

vgchange -a y lvm # Continue

mkfs.ext4 -L void /dev/mapper/lvm-void
mkfs.ext4 -L copy /dev/mapper/lvm-copy
mkswap -L swap /dev/mapper/lvm-swap
mkfs.ext4 -L data /dev/mapper/lvm-data

mkdir -p /mnt
mount /dev/mapper/lvm-void /mnt # Continue

mkdir -p /mnt/boot
mount /dev/sda1 /mnt/boot # Continue

mkdir -p /mnt/copy
mount /dev/mapper/lvm-copy /mnt/copy

mkdir -p /mnt/data
mount /dev/mapper/lvm-data /mnt/data
mkdir -p /mnt/data/users
mkdir -p /mnt/data/trash
mkdir -p /mnt/data/virt/{cnt,vms}

mkdir -p /mnt/var/db/xbps/keys /mnt/usr/share
cp -a /usr/share/xbps.d /mnt/usr/share/
cp /var/db/xbps/keys/*.plist /mnt/var/db/xbps/keys

xbps-install -r /mnt -Sy base-system grub lvm2 cryptsetup
xbps-reconfigure -r /mnt -f base-files

cp /etc/resolv.conf /mnt/etc/resolv.conf.head
cp /etc/rc.conf /mnt/etc

blkid /dev/sda2
export UUID="oAlBnS-ip37-PVLo-dWZO-t1Dm-AU28-m3wG36" # From blkid

xbps-uchroot /mnt /bin/bash

echo "luks-$UUID /dev/sda2  luks,discard" >> /etc/crypttab

echo "/dev/sda1 /boot ext4 defaults,discard,noatime 0 0" >> /etc/fstab
echo "/dev/mapper/luks-$UUID / ext4 defaults,discard,noatime 0 0" >> /etc/fstab
echo "/dev/mapper/lvm-copy /copy ext4 defaults,discard,noatime 0 0" >> /etc/fstab
echo "/dev/mapper/lvm-data /data ext4 defaults,discard,noatime 0 0" >> /etc/fstab
echo "/dev/mapper/lvm-swap none swap defaults,discard,noatime 0 0" >> /etc/fstab
echo "/data/users /home none bind 0 0" >> /etc/fstab
#echo "luks-$UUID /dev/sda2 /crypto_keyfile.bin luks" >> /etc/crypttab

#dd if=/dev/urandom of=/mnt/crypto_keyfile.bin bs=512 count=8 iflag=fullblock # generate a random key

more /etc/fstab
#more /etc/crypttab

#cryptsetup luksAddKey /dev/sda2 /crypto_keyfile.bin # add the key

mkdir -p /etc/dracut.conf.d
#echo 'install_items+="/etc/crypttab /crypto_keyfile.bin"' >> /etc/dracut.conf.d/10-crypt.conf
echo 'install_items+="/etc/crypttab"' > /etc/dracut.conf.d/10-crypt.conf

more /etc/dracut.conf.d/10-crypt.conf

mkdir -p /boot/grub

echo -e 'GRUB_DISABLE_SUBMENU=true' >> /etc/default/grub
echo -e 'GRUB_DISABLE_OS_PROBER=true' >> /etc/default/grub
echo -e 'GRUB_CMDLINE_LINUX="cryptdevice=/dev/sda2 rd.luks=1 rd.luks.uuid='"$UUID"' rd.luks.crypttab=1 rd.lvm=1 rd.md=0 rd.dm=0 lang=de locale=de_DE.UTF-8" pci=nomsi elevator=deadline' >> /etc/default/grub

echo -e '#!/bin/sh\nvbf' /etc/grub.d/40_custom

more /etc/default/grub

grub-mkconfig -o /boot/grub/grub.cfg # create initramfs image
grub-install --force /dev/sda # install grub

more /boot/grub/grub.cfg

xbps-reconfigure -f linux4.11 # recompile the current kernel (whilst ignoring locale errors)

ls -la /boot

# https://blog.packagecloud.io/eng/2017/02/21/set-environment-variable-save-thousands-of-system-calls/
echo 'TIMEZONE="Europe/Berlin"' >> /etc/rc.conf
echo 'HARDWARECLOCK="UTC"' >> /etc/rc.conf
echo 'KEYMAP="de-latin1-nodeadkeys"' >> /etc/rc.conf
echo 'HOSTNAME="void-vm"' >> /etc/rc.conf
echo 'FONT="lat9w-16"' >> /etc/rc.conf

ln -s /usr/share/zoneinfo/Europe/Berlin /etc/localtime
echo 'void-vm' > /etc/hostname

echo 'LANG="de_DE.UTF-8"' > /etc/locale.conf
echo 'de_DE.UTF-8 UTF-8' >> /etc/default/libc-locales
xbps-reconfigure -f glibc-locales

chsh -s /bin/bash # change the default shell for root
passwd # change root password

# Disable ipv6
mkdir -p /etc/sysctl.d
echo 'net.ipv6.conf.all.disable_ipv6 = 1' > /etc/sysctl.d/01-disable-ipv6.conf

# Enable networking
# https://wiki.voidlinux.eu/Network_Configuration
ln -s /etc/sv/dhcpcd /var/service/

# Enable wheel group
visudo
# %wheel   ALL=(ALL) ALL
# %wheel ALL=(ALL) NOPASSWD: /usr/bin/halt, /usr/bin/poweroff, /usr/bin/reboot, /usr/bin/shutdown, /usr/bin/zzz, /usr/bin/ZZZ

exit

# vgchange -a n lvm
# cryptsetup luksClose luks

reboot