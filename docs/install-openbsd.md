# Install OpenBSD

Notes for installing and setting up OpenBSD 7.5 on my desktop computer.

## Pre-Installation

Download and verify the installation image:

    $ ftp https://cdn.openbsd.org/pub/OpenBSD/7.5/amd64/install75.img
    $ ftp https://cdn.openbsd.org/pub/OpenBSD/7.5/amd64/SHA256
    $ sha256 -C SHA256 install75.img

Write the installation image to the target device:

    $ sysctl hw.disknames
    $ doas dd if=install75.img of=/dev/rsdXc bs=1M

Download the firmware packages required for my system:

    $ ftp http://firmware.openbsd.org/firmware/7.5/amd-firmware-20240220.tgz
    $ ftp http://firmware.openbsd.org/firmware/7.5/amdgpu-firmware-20240220.tgz
    $ ftp http://firmware.openbsd.org/firmware/7.5/iwm-firmware-20230330.tgz
    $ ftp http://firmware.openbsd.org/firmware/7.5/vmm-firmware-1.16.3.tgz
    $ ftp http://firmware.openbsd.org/firmware/7.5/SHA256.sig

Copy the firmware packages and my post-installation script to a USB drive:

    $ sysctl hw.disknames
    $ doas disklabel sdX
    $ doas mount /dev/sdXX /mnt
    $ doas mkdir -p /mnt/firmware
    $ doas cp *-firmware-*.tgz SHA256.sig /mnt/firmware
    $ doas cp ~/.local/bin/setup-openbsd /mnt
    $ doas umount

## Installation

Choose `(I)nstall` and enter the following responses:

    System hostname = desktop-pc
    Network interface to configure = done
    DNS domain name = home.arpa
    DNS nameservers = none
    Start sshd(8) by default = no
    Do you want the X Window System to be started by xenodm(1) = no
    Setup a user = matt
    Full name for user matt = Matthew Taylor
    Which disk is the root disk = sd0
    Encrypt the root disk with a (p)assphrase or (k)eydisk = p
    Use (W)hole disk MBR, whole disk (G)PT, (O)penBSD area or (E)dit = g
    Use (W)hole disk MBR, whole disk (G)PT or (E)dit = g
    Use (A)uto layout, (E)dit auto layout, or create (C)ustom layout = c

      a:   2097152   1G  /
      b:  50331648  24G  swap
      d:   8388608   4G  /tmp
      e:  75497472  36G  /var
      f:  62914560  30G  /usr
      g:   2097152   1G  /usr/X11R6
      h:  41943040  20G  /usr/local
      j:   6291456   3G  /usr/src
      k:  12582912   6G  /usr/obj
      l:              *  /home

    Which disk do you wish to initialize = done
    Location of sets = disk
    Is the disk partition already mounted = no
    Which disk contains the install media = sd2
    Which sd2 partition has the install sets = a
    Pathname to the sets = 7.5/amd64
    Set name(s) = done
    Directory does not contain SHA256.sig. Continue without verification = yes
    Location of sets = done
    What timezone are you in = Europe/London

## Post-Installation

Switch to the root user:

    $ su

Run my post-installation script from the USB drive and restart the system:

    # sysctl hw.disknames
    # disklabel sdX
    # mount /dev/sdXX /mnt
    # sh /mnt/setup-openbsd
    # umount /mnt
    # reboot
