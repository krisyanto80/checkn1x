#!/bin/bash
# odysseyn1x build script
# Forked by raspberryenvoie from asineth/checkn1x
#
# This build script has not been tested on 32-bit systems.

# Exit if user isn't root
[[ $EUID -ne 0 ]] && { echo 'Please run as root'; exit; }

# Change these variables to modify the version of checkra1n
checkra1n_amd64='https://assets.checkra.in/downloads/linux/cli/x86_64/fa08102ba978746ff38fc4c1a0d2e8f231c2cbf79c7ef6d7b504e4683a5b7d05/checkra1n'
checkra1n_i686='https://assets.checkra.in/downloads/linux/cli/i486/6f3885184dbdb5af4fec8c57e5684f914b9838ce7d6f78db5e9d2687d741b8f1/checkra1n'

cat << EOF
############################################
#                                          #
#  Welcome to the odysseyn1x build script  #
#                                          #
############################################

EOF

# Ask for the version and architecture if variables are empty
while [[ -z $VERSION ]]; do
  read -p 'What is the version? ' VERSION
done
echo ''
until [[ $ARCH = 'amd64' || $ARCH = 'i686' ]]; do
  echo '1 For amd64'
  echo '2 For i686'
  read -p 'Build for amd64 or for i686? (default: amd64) ' input_arch
  [[ $input_arch = 1 ]] && ARCH='amd64'
  [[ $input_arch = 2 ]] && ARCH='i686'
  [[ -z $input_arch ]] && ARCH='amd64'
done

# Display chosen configuration
echo "Building odysseyn1x $VERSION for $ARCH..."

# Delete old build
{
  umount -lf work/chroot/proc
  umount -lf work/chroot/sys
  umount -lf work/chroot/dev
}  > /dev/null 2>&1
rm -rf work/

set -e -u -v
SECONDS=0

# Install dependencies to build odysseyn1x
apt-get update
apt-get install -y --no-install-recommends wget debootstrap grub-pc-bin \
  grub-efi-amd64-bin mtools squashfs-tools xorriso ca-certificates curl \
  libusb-1.0-0-dev gcc make gzip xz-utils

# Install depencies to build odysseyn1x for i686
[[ $ARCH = 'i686' ]] && dpkg --add-architecture i386 && apt-get update \
  && apt install -y --no-install-recommends libusb-1.0-0-dev:i386 gcc-multilib

# Configure the base system
if [[ $ARCH = 'i686' ]]; then
  _ARCH='i386' # Debian's 32-bit repos are "i386"
else
  _ARCH='amd64' # Debian's 64-bit repos are "amd64"
fi
mkdir -p work/{chroot,iso/{live,boot/grub}}
debootstrap --arch=$_ARCH stable work/chroot
mount --bind /proc work/chroot/proc
mount --bind /sys work/chroot/sys
mount --bind /dev work/chroot/dev
cp /etc/resolv.conf work/chroot/etc
[[ $ARCH = "i686" ]] && _ARCH="686" # Debian's 32-bit kernels are suffixed "-686"
cat << EOF | chroot work/chroot /bin/bash

# Set debian frontend to noninteractive
export DEBIAN_FRONTEND=noninteractive

# Install requiered packages
apt-get install -y --no-install-recommends linux-image-$_ARCH live-boot \
  usbmuxd libusbmuxd-tools openssh-client sshpass psmisc xz-utils

# Change initramfs compression to xz
sed -i 's/COMPRESS=gzip/COMPRESS=xz/' /etc/initramfs-tools/initramfs.conf
update-initramfs -u

# Empty some directories to make the system smaller
rm -f /etc/mtab
rm -f /etc/fstab
rm -f /etc/ssh/ssh_host*
rm -f /root/.wget-hsts
rm -f /root/.bash_history
rm -rf /var/log/*
rm -rf /var/cache/*
rm -rf /var/backups/*
rm -rf /var/lib/apt/*
rm -rf /var/lib/dpkg/*
rm -rf /usr/share/doc/*
rm -rf /usr/share/man/*
rm -rf /usr/share/info/*
rm -rf /usr/share/icons/*
rm -rf /usr/lib/modules/*
exit
EOF

# Copy scripts
cp scripts/* work/chroot/usr/bin/

# Download resources for odysseyra1n
mkdir -p work/chroot/root/odysseyra1n/
cd work/chroot/root/odysseyra1n/
curl -L -O 'https://github.com/coolstar/odyssey-bootstrap/raw/master/bootstrap_1500-ssh.tar.gz'\
  -O 'https://github.com/coolstar/odyssey-bootstrap/raw/master/bootstrap_1600-ssh.tar.gz' \
  -O 'https://github.com/coolstar/odyssey-bootstrap/raw/master/migration' \
  -O 'https://github.com/coolstar/odyssey-bootstrap/raw/master/org.coolstar.sileo_1.8.1_iphoneos-arm.deb'
# Change compression format to xz
gzip -dv ./*.tar.gz
xz -v9e -T0 ./*.tar
cd -

# Download resources for Android Sandcastle
cd work/chroot/root/
curl -L -O 'https://assets.checkra.in/downloads/sandcastle/dff60656db1bdc6a250d3766813aa55c5e18510694bc64feaabff88876162f3f/android-sandcastle.zip'
unzip android-sandcastle.zip
rm -f android-sandcastle.zip android-sandcastle/{iproxy,*.dylib,load-linux.mac,*.sh,README.txt}

# Download resources for Linux Sandcastle
curl -L -O https://assets.checkra.in/downloads/sandcastle/0175ae56bcba314268d786d1239535bca245a7b126d62a767e12de48fd20f470/linux-sandcastle.zip
unzip linux-sandcastle.zip
rm -f linux-sandcastle.zip linux-sandcastle/{load-linux.mac,README.txt}
cd -

cd work/chroot/usr/bin/
curl -L -O https://raw.githubusercontent.com/corellium/projectsandcastle/master/loader/load-linux.c
# Build load-linux.c and download checkra1n for the corresponding architecture
if [[ $ARCH = 'amd64' ]]; then
  gcc load-linux.c -o load-linux -lusb-1.0
  curl -L -o checkra1n $checkra1n_amd64
else
  gcc -m32 load-linux.c -o load-linux -lusb-1.0
  curl -L -o checkra1n $checkra1n_i686
fi
rm -f load-linux.c
chmod +x load-linux checkra1n
cd -

# Configure autologin
mkdir -p work/chroot/etc/systemd/system/getty@tty1.service.d
cat << EOF > work/chroot/etc/systemd/system/getty@tty1.service.d/override.conf
[Service]
ExecStart=
ExecStart=-/sbin/agetty --noissue --autologin root %I
Type=idle
EOF

# Display booting message
cat << EOF > work/iso/boot/grub/grub.cfg
insmod all_video
echo 'odysseyn1x-$VERSION'
echo 'Made with <3 by raspberryenvoie'
linux /boot/vmlinuz boot=live quiet
initrd /boot/initrd.img
boot
EOF

# Change hostname and configure .bashrc
echo 'odysseyn1x' > work/chroot/etc/hostname
echo '/usr/bin/odysseyn1x_menu' > work/chroot/root/.bashrc

rm -f work/chroot/etc/resolv.conf

# Build the ISO
umount -lf work/chroot/proc
umount -lf work/chroot/sys
umount -lf work/chroot/dev
cp work/chroot/vmlinuz work/iso/boot
cp work/chroot/initrd.img work/iso/boot
mksquashfs work/chroot work/iso/live/filesystem.squashfs -noappend -e boot -comp xz -Xbcj x86
grub-mkrescue -o odysseyn1x-"$VERSION"-$ARCH.iso work/iso --compress=xz

echo "Built odysseyn1x-$VERSION-$ARCH in $((SECONDS / 60)) minutes and $((SECONDS % 60)) seconds."
