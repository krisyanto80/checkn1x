# odysseyn1x

Linux-based distribution for jailbreaking iOS devices w/ checkra1n and odysseyra1n.

## Downloads

Downloads are available under [releases](https://github.com/raspberryenvoie/odysseyn1x/releases).

## Usage

* If you are unsure which one to download, use the ``amd64`` one.
1. Download [balenaEtcher](https://www.balena.io/etcher/)
2. Open the ``.iso`` you downloaded.
3. Write it to your USB drive.
4. Reboot and enter your BIOS's boot menu.
5. Select the USB drive.

## Building

To change the version of checkra1n, edit ``CRSOURCE_amd64`` and ``CRSOURCE_i686``.

Execute one of these commands to build odysseyn1x.
```sh
# debian-based systems
sudo ./build.sh

# docker containers
docker run -it -v $(pwd):/app --rm --privileged debian:sid "cd /app && /app/build.sh"
```
## Credits
- Asineth for [checkn1x](https://github.com/asineth/checkn1x)
- The Checkra1n team for [checkra1n](https://checkra.in)
- Coolstar for [odysseyra1n](https://github.com/coolstar/Odyssey-bootstrap)
- [u/GOGO307](https://www.reddit.com/user/GOGO307/) for the concept
