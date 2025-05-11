#!/bin/bash

set -e

echo "Installing in UEFI mode."

# Unmount /dev/sda1 if it's already mounted
if mount | grep -q "/dev/sda1"; then
  echo "Unmounting /dev/sda1..."
  umount -f /dev/sda1
fi

# Wipe the disk
sgdisk --zap-all /dev/sda

# Create partitions
parted /dev/sda --script mklabel gpt
parted /dev/sda --script mkpart ESP fat32 1MiB 300MiB
parted /dev/sda --script set 1 boot on
parted /dev/sda --script mkpart primary ext4 300MiB 100%

# Format partitions
mkfs.fat -F32 /dev/sda1
mkfs.ext4 /dev/sda2

# Mount
mount /dev/sda2 /mnt
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot

# Set timezone and locale
ln -sf /usr/share/zoneinfo/Asia/Krasnoyarsk /mnt/etc/localtime
arch-chroot /mnt hwclock --systohc
echo "en_US.UTF-8 UTF-8" >> /mnt/etc/locale.gen
arch-chroot /mnt locale-gen
echo "LANG=en_US.UTF-8" > /mnt/etc/locale.conf

# Hostname
echo "archlinux" > /mnt/etc/hostname

# Install base system
pacstrap /mnt base linux linux-firmware grub efibootmgr

# Generate fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Install GRUB
arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

echo "Installation complete. You can now reboot."
