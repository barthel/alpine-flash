# cloud-init sample config files

Here you can find a collection of sample configurations to improve your
first-boot experience using AlpineOS.

With cloud-init you can customize your device automatically during the first initial boot.
See the [cloud-init documentation](http://cloudinit.readthedocs.io/en/latest/) for more details.

You can either use the `flash` tool with option `-u` or `--userdata` to specify the YAML file. The flash tool will copy it to the SD card right after flashing.

Otherwise copy the YAML file to the boot partition of the SD card to the `/boot/user-data` file.

Quick installation:

```
$ flash -u your-cloud-init.yml https://github.com/barthel/alpine-image-builder-rpi/releases/download/3.21.0/alpineos-rpi-3.21.0.img.zip
$ ssh admin@alpine-black-pearl.local
```

## WiFi

Setup WiFi for your Raspberry Pi Zero W.

* [wifi-user-data.yml](./wifi-user-data.yml)
  * insert WiFi SSID
  * adjust your country code

## SSH public key authentication

Setup your device with a different user account, remove default user and password.

* [ssh-pub-key.yml](./ssh-pub-key.yml)
  * adjust user name
  * insert SSH public key

## Static IP address

Setup your eth0 device with a static IP address.

* [static.yml](./static.yml)

## Hands-free Docker projects

Run a container as a service automatically.

* [rainbow.yml](./rainbow.yml)
  * insert SSH public key
  * insert WiFi SSID and preshared key
  * adjust your country code
  * attach Pimoroni Blinkt
  * flash, boot your Pi Zero W - enjoy!
