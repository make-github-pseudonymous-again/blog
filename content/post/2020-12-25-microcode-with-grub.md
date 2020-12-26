+++
+++

Install Intel or AMD package:

    pacman -S intel-ucode

or

    pacman -S amd-ucode

Regenerate GRUB config

    grub-mkconfig -o /boot/grub/grub.cfg
