#!/bin/bash

# Update the system
sudo pacman -Syu --noconfirm

# Install essential packages
sudo pacman -S base-devel git wget --noconfirm

# Install yay for AUR packages
cd /opt
sudo git clone https://aur.archlinux.org/yay.git
sudo chown -R $(whoami):$(whoami) yay
cd yay
makepkg -si --noconfirm

# Install NVIDIA drivers and utilities
sudo pacman -S nvidia-dkms nvidia-utils lib32-nvidia-utils nvidia-settings --noconfirm

# Install AMD GPU drivers
sudo pacman -S xf86-video-amdgpu --noconfirm

# Install ASUS Control
yay -S asusctl supergfxctl --noconfirm

# Install Hyprland and related utilities
yay -S hyprland-git waybar-hyprland wlogout swww xdg-desktop-portal-hyprland --noconfirm

# Configure NVIDIA settings for Wayland and Hyprland
sudo bash -c 'echo "options nvidia-drm modeset=1" > /etc/modprobe.d/nvidia.conf'
sudo bash -c 'echo "MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)" > /etc/mkinitcpio.conf'

# Generate new initramfs
sudo mkinitcpio -P

# Set environment variables for Hyprland
echo 'export LIBVA_DRIVER_NAME=nvidia' >> ~/.bashrc
echo 'export XDG_SESSION_TYPE=wayland' >> ~/.bashrc
echo 'export GBM_BACKEND=nvidia-drm' >> ~/.bashrc
echo 'export __GLX_VENDOR_LIBRARY_NAME=nvidia' >> ~/.bashrc
echo 'export WLR_NO_HARDWARE_CURSORS=1' >> ~/.bashrc

# Create scripts directory in home folder and add it to PATH
mkdir -p ~/scripts
echo 'export PATH=$PATH:~/scripts' >> ~/.bashrc

# Reload bashrc
source ~/.bashrc

# Configure systemd-boot
sudo bash -c 'echo "options nvidia-drm.modeset=1" >> /boot/loader/entries/arch.conf'

# Enable services for suspend and resume
sudo systemctl enable nvidia-suspend.service nvidia-hibernate.service nvidia-resume.service

# Reboot to apply changes
echo "Installation complete. The system will now reboot."
sudo reboot
