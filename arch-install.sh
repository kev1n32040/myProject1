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
umount -R /mnt || true
wipefs -af "$disk"
sgdisk -Zo "$disk"

if [ "$boot_mode" = "UEFI" ]; then
    # UEFI: EFI + root
    sgdisk -n1:0:+300M -t1:ef00 "$disk"
    sgdisk -n2:0:0     -t2:8300 "$disk"
    part_boot="${disk}1"
    part_root="${disk}2"
else
    # BIOS: BIOS boot + root
    sgdisk -a1 -n1:2048:+1M -t1:ef02 "$disk"
    sgdisk -n2:0:0     -t2:8300 "$disk"
    part_boot=""
    part_root="${disk}2"
fi

sleep 2

# Форматирование
if [ "$boot_mode" = "UEFI" ]; then
    mkfs.fat -F32 "$part_boot"
fi
mkfs.ext4 -F "$part_root"

# Монтирование
mount "$part_root" /mnt
if [ "$boot_mode" = "UEFI" ]; then
    mkdir -p /mnt/boot
    mount "$part_boot" /mnt/boot
fi

# Установка базовой системы
pacstrap /mnt base linux linux-firmware bash sudo nano networkmanager grub efibootmgr

# Генерация fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Настройка в chroot
arch-chroot /mnt /bin/bash <<EOF
ln -sf /usr/share/zoneinfo/$timezone /etc/localtime
hwclock --systohc

echo "$locale" > /etc/locale.gen
locale-gen
echo "LANG=$locale_conf" > /etc/locale.conf

echo "$hostname" > /etc/hostname
cat <<HOSTS > /etc/hosts
127.0.0.1   localhost
::1         localhost
127.0.1.1   $hostname.localdomain $hostname
HOSTS

# Создание пользователя
useradd -m -G wheel -s /bin/bash $username
echo "$username:$password" | chpasswd
echo "root:$password" | chpasswd

# Разрешаем sudo для wheel
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

# Включаем сетевые службы
systemctl enable NetworkManager

# Установка GRUB
if [ "$boot_mode" = "UEFI" ]; then
    mkdir -p /boot/EFI
    grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
else
    grub-install --target=i386-pc "$disk"
fi

grub-mkconfig -o /boot/grub/grub.cfg
EOF

echo -e "\n✅ Установка завершена! Можно перезагружать."
