#!/bin/bash

set -e

DISK="/dev/sda"
HOSTNAME="archhypr"
USERNAME="user"
PASSWORD="password"
TIMEZONE="Asia/Krasnoyarsk"

# Разметка и форматирование
parted -s $DISK mklabel gpt
parted -s $DISK mkpart ESP fat32 1MiB 512MiB
parted -s $DISK set 1 esp on
parted -s $DISK mkpart primary ext4 512MiB 100%

mkfs.fat -F32 ${DISK}1
mkfs.ext4 ${DISK}2

# Монтирование
mount ${DISK}2 /mnt
mkdir /mnt/boot
mount ${DISK}1 /mnt/boot

# Базовая система
pacstrap -K /mnt base linux linux-firmware grub efibootmgr networkmanager sudo git neovim

# fstab
genfstab -U /mnt >> /mnt/etc/fstab

# chroot
arch-chroot /mnt /bin/bash <<EOF

# Язык и часовой пояс
ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
hwclock --systohc
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Хостнейм и сеть
echo "$HOSTNAME" > /etc/hostname
echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1       localhost" >> /etc/hosts
echo "127.0.1.1 $HOSTNAME.localdomain $HOSTNAME" >> /etc/hosts

# Пользователь
useradd -m -G wheel -s /bin/bash $USERNAME
echo "$USERNAME:$PASSWORD" | chpasswd
echo "root:$PASSWORD" | chpasswd
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

# Загрузчик
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

# Сеть
systemctl enable NetworkManager

EOF

umount -R /mnt
echo "Установка завершена. Перезагрузитесь!"
