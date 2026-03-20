# alpine-flash

Command line script to flash Alpine Linux SD card images for Raspberry Pi.

Note that at the end of the flashing process the tool tries to customize the SD card e.g. it configures a hostname or WiFi. And with a cloud-init enabled image you can do much more like adding users, SSH keys etc.

The typical workflow looks like this:

1. Run `flash https://github.com/barthel/alpine-image-builder-rpi/releases/download/v1.0.0/alpineos-rpi-v1.0.0.img.zip`
2. Insert SD card to your notebook
3. Press RETURN
4. Eject SD card and insert it to your Raspberry Pi - done!

This script can

* download a compressed SD card from the internet or from S3
* use a local SD card image, either compressed or uncompressed
* wait until a SD card is plugged in
* search for a SD card plugged into your Computer
* show progress bar while flashing (if `pv` is installed)
* copy an optional cloud-init `user-data` and `meta-data` file into the boot partition of the SD image
* copy an optional `config.txt` file into the boot partition of the SD image (eg. to enable onboard WiFi)
* copy an optional custom file into the boot partition of the SD image
* optional set the hostname of this SD image
* optional set the WiFi settings as well
* play a little sound after flashing
* unplugs the SD card

At the moment only Mac OS X and Linux is supported.

## Installation

Download the appropriate version for Linux or Mac with this command

```bash
curl -LO https://github.com/barthel/alpine-flash/releases/download/1.0.0/flash
chmod +x flash
sudo mv flash /usr/local/bin/flash
```

### Install Dependencies

The `flash` script needs optional tools

* `curl` - if you want to flash directly with an HTTP URL
* `aws` - if you want to flash directly from an AWS S3 bucket
* `pv` - to see a progress bar while flashing with the `dd` command
* `unzip` - to extract zip files.
* `hdparm` - to run the program

#### Mac

```bash
brew install pv
brew install awscli
```

#### Linux (Debian/Ubuntu)

```bash
sudo apt-get install -y pv curl python3-pip unzip hdparm
sudo pip3 install awscli
```

## Usage

```bash
$ flash --help
usage: flash [options] [name-of-rpi.img]

Flash a local or remote Raspberry Pi SD card image.

OPTIONS:
  --help|-h       Show this message
  --bootconf|-C   Copy this config file to /boot/config.txt
  --config|-c     Copy this config file to /boot/device-init.yaml (or occidentalis.txt)
  --hostname|-n   Set hostname for this SD image
  --ssid|-s       Set WiFi SSID for this SD image
  --password|-p   Set WiFI password for this SD image
  --clusterlab|-l Start Cluster-Lab on boot: true or false
  --device|-d     Card device to flash to (e.g. /dev/sdb in Linux or /dev/disk2 in OSX)
  --force|-f      Force flash without security prompt (for automation)
  --userdata|-u   Copy this cloud-init file to /boot/user-data
  --metadata|-m   Copy this cloud-init file to /boot/meta-data
  --file|-F       Copy this file to /boot
```

## Configuration

The strength of the flash tool is that it can insert some configuration files that gives you the best first boot experience to customize the hostname, WiFi and even user logins and SSH keys automatically.

### cloud-init

The options `--userdata` and `--metadata` can be used to copy both cloud-init config files into the FAT partition.

This is an example how to create the default user with a password.

```yaml
#cloud-config
# vim: syntax=yaml
#
hostname: alpine-black-pearl
manage_etc_hosts: true

users:
  - name: admin
    gecos: "Alpine Admin"
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    groups: users,docker,video
    lock_passwd: false
    ssh_pwauth: true
    chpasswd: { expire: false }

package_upgrade: false
```

Please have a look at the [`sample`](sample/) folder or at the [cloud-init documentation](http://cloudinit.readthedocs.io/en/latest/)
how to do more things like using SSH keys, running additional commands etc.

### config.txt

The option `--bootconf` can be used to copy a `config.txt` into the SD image
before it is unplugged.

With this option it is possible to change some memory, camera, video settings
etc. See the [config.txt documentation](https://www.raspberrypi.org/documentation/configuration/config-txt/README.md)
at raspberrypi.org for more details.

The boot config file config.txt has name/value pairs such as:

```bash
max_usb_current=1
hdmi_force_hotplug=1
```

## Use cases

### Flash a compressed SD image from the internet

```bash
flash https://github.com/barthel/alpine-image-builder-rpi/releases/download/v1.0.0/alpineos-rpi-v1.0.0.img.zip
```

### Flash and change the hostname

```bash
flash --hostname mypi alpineos-rpi.img
```

Then unplug the SD card from your computer, plug it into your Pi and boot your
Pi. After a while the Pi can be found via Bonjour/avahi and you can log in with

```bash
ssh admin@mypi.local
```

### Onboard WiFi

The options `--userdata` and `--bootconf` must be used to disable UART and enable onboard WiFi for Raspberry Pi Zero W. For external WiFi sticks you do not need to specify the `-bootconf` option.

```
flash --userdata sample/wifi-user-data.yml --bootconf sample/no-uart-config.txt alpineos-rpi-v1.0.0.img
```

### Automating flash

For non-interactive usage, you can predefine the user input in the flash command with the `-d` and `-f` options:

```
flash -d /dev/mmcblk0 -f alpineos-rpi-v1.0.0.img
```

## Development

Pull requests and other feedback is always welcome. The `flash` tool should fit
our all needs and environments.

To develop the flash scripts you need either a Linux or macOS machine to test locally. On a Mac you can use Docker to run the Linux tests in a container.

### Local development

The flash script are checked with the [`shellcheck`](https://www.shellcheck.net) static analysis tool.

The integration tests can be run locally on macOS or Linux. We use BATS which is installed with NPM package. So you would need Node.js to setup a local development environment.

```
npm install
npm test
```

### Isolated tests with Docker

If you do not want to install all these development tools (shellcheck, bats, node) you can use Docker instead.

All you need is Docker and `make` installed to run the following tests.

#### Shellcheck

```
make shellcheck
```

#### Integration tests

```
make test
```
