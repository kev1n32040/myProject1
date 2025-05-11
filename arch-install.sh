#!/bin/bash

# Устанавливаем зеркало поближе
reflector --country Russia --latest 5 --sort rate --save /etc/pacman.d/mirrorlist

# Устанавливаем ntp
timedatectl set-ntp true

# Разметка диска
umount -R /mnt 2>/dev/null
wipefs -a /dev/sda
parted -s /dev/sda mklabel gpt
parted -s /dev/sda mkpart primary ext4 1MiB 100%
mkfs.ext4 /dev/sda1
mount /dev/sda1 /mnt

# Установка базовой системы
pacstrap /mnt base linux linux-firmware sudo vim grub

# Генерация fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Настройка внутри установленной системы
arch-chroot /mnt /bin/bash -e <<EOF

# Установка временной зоны и локали
ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime
hwclock --systohc
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Сетевое имя
echo arch-pc > /etc/hostname

# Hosts
cat <<EOT > /etc/hosts
127.0.0.1   localhost
::1         localhost
127.0.1.1   arch-pc.localdomain arch-pc
EOT

# Пароль root
echo root:root | chpasswd

# Создание пользователя user с паролем 1234
useradd -m -G wheel -s /bin/bash user
echo user:1234 | chpasswd

# Разрешение sudo
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

# Установка загрузчика
grub-install --target=i386-pc /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg
EOF

# Готово
echo "Установка завершена. Перезагрузитесь после выхода."
