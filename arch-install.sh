#!/bin/bash

set -e

echo "Installing in UEFI mode."

# Удаляем все старые разделы
umount -R /mnt || true
sgdisk -Z /dev/sda

# Создание новых GPT-разделов
sgdisk -n 1:0:+300M -t 1:ef00 /dev/sda  # EFI
sgdisk -n 2:0:0     -t 2:8300 /dev/sda  # Root

# Форматирование
mkfs.fat -F32 /dev/sda1
mkfs.ext4 -F /dev/sda2

# Монтирование
mount /dev/sda2 /mnt
mkdir -p /mnt/boot/efi
mount /dev/sda1 /mnt/boot/efi

# Установка базовой системы
pacstrap /mnt base linux linux-firmware grub efibootmgr networkmanager sudo

# Генерация fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Настройка системы через chroot
arch-chroot /mnt /bin/bash <<EOF
ln -sf /usr/share/zoneinfo/Asia/Krasnoyarsk /etc/localtime
hwclock --systohc
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "archlinux" > /etc/hostname

# Сетевой конфиг
cat > /etc/hosts <<EOL
127.0.0.1   localhost
::1         localhost
127.0.1.1   archlinux.localdomain archlinux
EOL

# Установка загрузчика
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
EOF

echo "Installation complete. You can now reboot."
