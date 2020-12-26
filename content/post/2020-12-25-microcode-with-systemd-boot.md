+++
+++

Install Intel or AMD package:

    pacman -S intel-ucode

or

    pacman -S amd-ucode


Add initrd line to boot loader config:

    title Arch Linux
    linux /vmlinuz-linux
    initrd /intel-ucode.img
    initrd /initramfs-linux.img
    options ...

or 

    title Arch Linux
    linux /vmlinuz-linux
    initrd /amd-ucode.img
    initrd /initramfs-linux.img
    options ...
