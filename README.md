<h1 align="center">odysseyn1x</h1>
<h3 align="center">Linux-based distro that lets you install checkra1n, odysseyra1n and Project Sandcastle.</h3>
<p align="center"><img src="https://raw.githubusercontent.com/raspberryenvoie/odysseyn1x/master/Screenshot.png" alt="Screenshot"></p>

-------

## Usage

**Make an [iCloud/iTunes backup](https://support.apple.com/en-us/HT203977) before using odysseyn1x, so that you can go back if something goes wrong.**

The `amd64` iso is for 64-bit CPUs (AMD and Intel) and the `i686` one is for 32-bit CPUs.
If you are unsure which one to download, the `amd64` iso will work in most cases.

1. Download an `.iso` [here](https://github.com/raspberryenvoie/odysseyn1x/releases).
2. Download [balenaEtcher](https://www.balena.io/etcher/). Rufus may not work, but you can try it.
3. Open balenaEtcher and write the `.iso` you downloaded to your USB drive.
4. Reboot, enter your BIOS's boot menu and select the USB drive.

## Odysseyra1n
**What's odysseyra1n:** Odysseyra1n is a modern replacement bootstrap (basically a set of compiled tools) made by Coolstar that offers better speed and stability using libhooker as injection and hooking library, and some users have better battery life too. It installs Sileo instead of aging Cydia.

1. Restore rootfs using the ckeckra1n app.
2. Jailbreak using checkra1n, but don’t open the loader.
3. Install odysseyra1n.
4. OpenSSH is installed by default, **please change the default mobile/root passwords**.

### Changing the default passwords

OpenSSH is installed by default, so please change the mobile/root passwords to prevent the possibility of unsavory people remotely logging into your device using the default password.\
*Default/old password: `alpine`*

1. Install Newterm in Sileo.
2. Open it and type `passwd mobile` to change the mobile user's password.
3. Then, execute `su` to login as root.
4. After that, run `passwd` to change its password.

## Project Sandcastle
**What's Project Sandcastle:** It's Android and Linux for the iPhone. Project Sandcastle is in beta so not everything is fully supported. [More information](https://projectsandcastle.org)
### Installing Android
Select Project Sandcastle > Setup Project Sandcastle > Start Android.
When Project Sandcastle has been installed, simply choose "Start Android" to boot back into Android.

**Removing Android:**
If you wish to remove the Android NAND image and reclaim the space, you can login via SSH to your checkra1ned device, and mount the final volume, and remove the NAND file. To do this, run `ls /dev/disk0s1s*` and find the last volume. You can verify it's the right volume by running `/System/Library/Filesystems/apfs.fs/apfs.util -p VOLUME_HERE` and if it says Android, that's the correct one. Once you have the volume path, you can then run these commands as root (type `su`):
```
mkdir -p /tmp/mnt
mount -t apfs VOLUME_HERE /tmp/mnt
rm -rf /tmp/mnt/nand
umount /tmp/mnt
sync
```
and that will reclaim the space for you.

### Booting Linux
Select "Project Sandcastle", then "Start Linux".

## Building

To change the version of checkra1n, edit `CRSOURCE_amd64` and `CRSOURCE_i686`.\
Execute these commands on a Debian-based system.
```
git clone https://github.com/raspberryenvoie/odysseyn1x.git
cd odysseyn1x
sudo ./build.sh
```
## Credits
- Asineth for checkn1x
- The checkra1n team for [checkra1n](https://checkra.in)
- CoolStar for [odysseyra1n](https://github.com/coolstar/Odyssey-bootstrap)
- [The Procursus Team](https://github.com/ProcursusTeam/) for [Procursus](https://github.com/ProcursusTeam/Procursus)
- [Corellium](https://github.com/corellium) for [Project Sandcastle](https://projectsandcastle.org)
- [u/GOGO307](https://www.reddit.com/user/GOGO307/) for the concept of an ISO with odysseyra1n
- [MyCatCondo](https://github.com/MyCatCondo) for suggesting to integrate Project Sandcastle (Android and Linux for the iPhone)
