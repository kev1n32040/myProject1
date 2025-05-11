#!/bin/bash

# Arch Linux Auto Install Script (BIOS + UEFI)
# Timezone: Asia/Krasnoyarsk
# Author: Keu1n (https://github.com/keu1n32040)

set -euo pipefail

# Variables
disk="/dev/sda"
hostname="archlinux"
username="user"
password="password"
timezone="Asia/Krasnoyarsk"
locale="en_US.UTF-8 UTF-8"
locale_conf="en_US.UTF-8"

# Проверка загрузки: UEFI или BIOS
if [ -d /sys/firmware/efi ]; then
    boot_mode="UEFI"
else
    boot_mode="BIOS"
fi

echo "Installing in $boot_mode mode..."

# Очистка и разметка диска
