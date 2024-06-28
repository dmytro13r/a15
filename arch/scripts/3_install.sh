#!/bin/bash

# Function to add a line to a file if it doesn't already exist
add_line_if_not_exists() {
    local file="$1"
    local line="$2"
    grep -qxF "$line" "$file" || echo "$line" | sudo tee -a "$file" > /dev/null
}

# Function to add a module to mkinitcpio.conf if it doesn't already exist
add_module_if_not_exists() {
    local module="$1"
    if ! grep -q "$module" /etc/mkinitcpio.conf; then
        sudo sed -i "s/^MODULES=(/MODULES=($module /" /etc/mkinitcpio.conf
    fi
}

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
add_line_if_not_exists "/etc/modprobe.d/nvidia.conf" "options nvidia-drm modeset=1"

# Add NVIDIA modules to mkinitcpio.conf
add_module_if_not_exists "nvidia"
add_module_if_not_exists "nvidia_modeset"
add_module_if_not_exists "nvidia_uvm"
add_module_if_not_exists "nvidia_drm"

# Generate new initramfs
sudo mkinitcpio -P

# Set environment variables for Hyprland
add_line_if_not_exists "$HOME/.bashrc" 'export LIBVA_DRIVER_NAME=nvidia'
add_line_if_not_exists "$HOME/.bashrc" 'export XDG_SESSION_TYPE=wayland'
add_line_if_not_exists "$HOME/.bashrc" 'export GBM_BACKEND=nvidia-drm'
add_line_if_not_exists "$HOME/.bashrc" 'export __GLX_VENDOR_LIBRARY_NAME=nvidia'
add_line_if_not_exists "$HOME/.bashrc" 'export WLR_NO_HARDWARE_CURSORS=1'

# Create scripts directory in home folder and add it to PATH
mkdir -p "$HOME/scripts"
add_line_if_not_exists "$HOME/.bashrc" 'export PATH=$PATH:$HOME/scripts'

# Reload bashrc
source "$HOME/.bashrc"

# Configure systemd-boot
sudo bash -c 'echo "options nvidia-drm.modeset=1" >> /boot/loader/entries/arch.conf'

# Enable services for suspend and resume
sudo systemctl enable nvidia-suspend.service nvidia-hibernate.service nvidia-resume.service

# Reboot to apply changes
echo "Installation complete. The system will now reboot."
sudo reboot
