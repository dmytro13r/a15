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

# Backup function
backup_file() {
    local file="$1"
    local backup_dir="$HOME/backups/installer_script/$(date +%Y-%m-%d)"
    mkdir -p "$backup_dir"
    cp "$file" "$backup_dir/$(basename $file).$(date +%H%M%S)"
}

# Update the system
sudo pacman -Syu --noconfirm

# Install essential packages
sudo pacman -S base-devel git wget polkit-kde-agent brightnessctl --noconfirm

# Install yay for AUR packages
cd /opt
sudo git clone https://aur.archlinux.org/yay.git
sudo chown -R $(whoami):$(whoami) yay
cd yay
makepkg -si --noconfirm

# Install NVIDIA / AMD GPU drivers and utilities
sudo pacman -S nvidia-dkms nvidia-utils lib32-nvidia-utils nvidia-settings xf86-video-amdgpu linux-headers --noconfirm
yay -S libva libva-nvidia-driver-git --noconfirm

# Install ASUS Control and related utilities
yay -S asusctl rog-control-center supergfxctl power-profiles-daemon --noconfirm
sudo pacman -S acpi psensor --noconfirm

# Install Xorg, i3wm, and related packages
sudo pacman -S xorg-server xorg-apps xorg-xinit i3-wm i3status dmenu terminator networkmanager --noconfirm

# Install additional utilities and applications
sudo pacman -S pavucontrol firefox keepassxc gucharmap otf-font-awesome ttf-nerd-fonts-symbols noto-fonts --noconfirm
yay -S google-chrome telegram-desktop discord timeshift pycharm-community-edition --noconfirm

# Enable NetworkManager
sudo systemctl enable NetworkManager

# Install and enable PipeWire (replacing PulseAudio)
sudo pacman -S pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber --noconfirm
systemctl --user enable pipewire pipewire-pulse wireplumber
systemctl --user start pipewire pipewire-pulse wireplumber

# Configure NVIDIA settings for Xorg
backup_file "/etc/modprobe.d/nvidia.conf"
add_line_if_not_exists "/etc/modprobe.d/nvidia.conf" "options nvidia-drm modeset=1"

# Add NVIDIA modules to mkinitcpio.conf
backup_file "/etc/mkinitcpio.conf"
add_module_if_not_exists "nvidia"
add_module_if_not_exists "nvidia_modeset"
add_module_if_not_exists "nvidia_uvm"
add_module_if_not_exists "nvidia_drm"

# Generate new initramfs
sudo mkinitcpio -P

# Set environment variables for NVIDIA
backup_file "$HOME/.bashrc"
add_line_if_not_exists "$HOME/.bashrc" 'export LIBVA_DRIVER_NAME=nvidia'
add_line_if_not_exists "$HOME/.bashrc" 'export __GLX_VENDOR_LIBRARY_NAME=nvidia'

# Create scripts directory in home folder and add it to PATH
mkdir -p "$HOME/scripts"
add_line_if_not_exists "$HOME/.bashrc" 'export PATH=$PATH:$HOME/scripts'
# Example symbolic link (adjust as needed)
# ln -s ~/a15/arch/dotconfig/update_dot.sh ~/scripts/update_dot.sh

# Reload bashrc
source "$HOME/.bashrc"

# Enable services for suspend and resume
sudo systemctl enable nvidia-suspend.service nvidia-hibernate.service nvidia-resume.service

# Add user to necessary groups
sudo gpasswd -a $USER video
sudo gpasswd -a $USER input

# Set ASUS keyboard backlight (adjust brightness level as needed)
asusctl -c 80

# Reboot to apply changes
echo "Installation complete. Please reboot your system."
