<h1 align="center">odysseyn1x</h1>
<h3 align="center">Linux-based distro that lets you install checkra1n, odysseyra1n and Project Sandcastle:.</h3>

-------

## Usage

**Make an [iCloud/iTunes backup](https://support.apple.com/en-us/HT203977) before using odysseyn1x, so that you can go back if something goes wrong.**

The `amd64` iso is for 64-bit CPUs (AMD and Intel) and the `i686` one is for 32-bit CPUs.
If you are unsure which one to download, the `amd64` iso will work in most cases.

1. Download an `.iso`.
2. Download [balenaEtcher](https://www.balena.io/etcher/).
3. Open balenaEtcher and write the `.iso` you downloaded to your USB drive.
4. Reboot, enter your BIOS's boot menu and select the USB drive.

### odysseyra1n
**What's odysseyra1n:** Odysseyra1n is a modern replacement bootstrap (basically a set of compiled tools) made by Coolstar that offers better speed and stability using libhooker as injection and hooking library and some users have better battery life too. It installs Sileo instead of aging Cydia.

1. Restore rootfs using the checkra1n app.
2. Jailbreak using checkra1n, but don’t open the loader.
3. Install odysseyra1n.
4. OpenSSH is installed by default, **please change the default root password**.

### Project Sandcastle:
**What's Project Sandcastle:** It's Android for the iPhone. Projectsandcastle is in beta so not everything is fully supported. [More information](https://projectsandcastle.org)

1. Select "Setup Project Sandcastle"
2. Then choose "Start Android"

When Project Sandcastle has been installed, simply choose "Start Android" to boot back into Android.

**Removing it:**
If you wish to remove the Android NAND image and reclaim the space you can login via SSH to your checkra1ned device and mount the final volume and remove the nand file. To do this run `ls /dev/disk0s1s*` and find the last volume. You can verify it's the right volume by running `/System/Library/Filesystems/apfs.fs/apfs.util -p VOLUME_HERE` and if it says Android, that's the correct one. Once you have the volume path you can then run as root (type `su`):
```
mkdir -p /tmp/mnt
mount -t apfs VOLUME_HERE /tmp/mnt
rm -rf /tmp/mnt/nand
umount /tmp/mnt
sync
```
And that will reclaim the space for you.

## Building

To change the version of checkra1n, edit `CRSOURCE_amd64` and `CRSOURCE_i686`.\
Execute these commands on a debian-based system.
```
git clone https://github.com/raspberryenvoie/odysseyn1x.git
cd odysseyn1x
sudo ./build.sh
```
## Credits
- Asineth for checkn1x
- The Checkra1n team for [checkra1n](https://checkra.in)
- CoolStar for [odysseyra1n](https://github.com/coolstar/Odyssey-bootstrap)
- [The Procursus team](https://github.com/ProcursusTeam/) for [Procursus](https://github.com/ProcursusTeam/Procursus)
- [Corellium](https://github.com/corellium) for [Project Sandcastle](https://projectsandcastle.org)
- [u/GOGO307](https://www.reddit.com/user/GOGO307/) for the concept of an iso with odysseyra1n
- [MyCatCondo](https://github.com/MyCatCondo) for suggesting to integrate Project Sandcastle
