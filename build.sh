#!/bin/sh
#
# checkn1x build script
# https://asineth.gq/checkn1x
#
VERSION="1.0.6"
ARCH="amd64" # can be set to amd64, i686
CRSOURCE_amd64="https://assets.checkra.in/downloads/linux/cli/x86_64/607faa865e90e72834fce04468ae4f5119971b310ecf246128e3126db49e3d4f/checkra1n"
CRSOURCE_i686="https://assets.checkra.in/downloads/linux/cli/i486/53d45283b5616d9f0daa8a265362b65a33ce503b3088528cc2839544e166d4c6/checkra1n"

set -e -u -v
apt update
apt install -y --no-install-recommends wget debootstrap grub-pc-bin grub-efi-amd64-bin mtools squashfs-tools xorriso ca-certificates curl
mkdir -p work/chroot
mkdir -p work/iso/live
mkdir -p work/iso/boot/grub
if [[ $ARCH = "i686" ]]; then
  _ARCH="i386" # debian's 32-bit repos are "i386"
else
  _ARCH="amd64" # debian's 64-bit repos are "amd64"
fi
debootstrap --arch=$_ARCH unstable work/chroot
mount --bind /proc work/chroot/proc
mount --bind /sys work/chroot/sys
mount --bind /dev work/chroot/dev
cp /etc/resolv.conf work/chroot/etc
[ $ARCH = "i686" ] && _ARCH="686" # debian's 32-bit kernels are suffixed "-686"
cat << EOF | chroot work/chroot /bin/bash
export DEBIAN_FRONTEND=noninteractive
apt install -y --no-install-recommends linux-image-$_ARCH live-boot usbmuxd libusbmuxd-tools keyboard-configuration
sed -i 's/COMPRESS=gzip/COMPRESS=xz/' /etc/initramfs-tools/initramfs.conf
update-initramfs -u
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

# Download resources for Odysseyra1n
cd work/chroot/root/
curl -L -O https://github.com/coolstar/odyssey-bootstrap/raw/master/bootstrap_1500-ssh.tar.gz -O https://github.com/coolstar/odyssey-bootstrap/raw/master/bootstrap_1600-ssh.tar.gz -O https://github.com/coolstar/odyssey-bootstrap/raw/master/migration -O https://github.com/coolstar/odyssey-bootstrap/raw/master/org.coolstar.sileo_1.8.1_iphoneos-arm.deb
# Copy scripts to /usr/bin/
cd ../../../
cp odysseyn1x odyseyra1n /usr/bin/

if [[ $ARCH = "amd64" ]]; then
  wget -O work/chroot/usr/bin/checkra1n $CRSOURCE_amd64
else
  wget -O work/chroot/usr/bin/checkra1n $CRSOURCE_i686
fi
chmod +x work/chroot/usr/bin/checkra1n
mkdir -p work/chroot/etc/systemd/system/getty@tty1.service.d
cat << EOF > work/chroot/etc/systemd/system/getty@tty1.service.d/override.conf
[Service]
ExecStart=-/sbin/agetty --noissue --autologin root %I
Type=idle
EOF
cat << EOF > work/iso/boot/grub/grub.cfg
insmod all_video
linux /boot/vmlinuz boot=live quiet
initrd /boot/initrd.img
boot
EOF
echo 'odysseyn1x' > work/chroot/etc/hostname
echo '/usr/bin/odysseyn1x' > work/chroot/root/.bashrc
rm -f work/chroot/etc/resolv.conf
umount -lf work/chroot/proc
umount -lf work/chroot/sys
umount -lf work/chroot/dev
cp work/chroot/vmlinuz work/iso/boot
cp work/chroot/initrd.img work/iso/boot
mksquashfs work/chroot work/iso/live/filesystem.squashfs -noappend -e boot -comp xz -Xbcj x86
grub-mkrescue -o odysseyn1x-$VERSION-$ARCH.iso work/iso
