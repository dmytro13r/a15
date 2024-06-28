#!/bin/bash

# Update the system package database
echo "Updating the system package database..."
sudo pacman -Syu --noconfirm

# Install prerequisites for building yay
echo "Installing prerequisites..."
sudo pacman -S --needed base-devel git --noconfirm

# Clone the yay repository into /opt directory
echo "Cloning the yay repository into /opt directory..."
sudo git clone https://aur.archlinux.org/yay.git /opt/yay

# Change ownership of the /opt/yay directory to the current user
echo "Changing ownership of the /opt/yay directory to the current user..."
sudo chown -R $(whoami):$(whoami) /opt/yay

# Change to the /opt/yay directory
cd /opt/yay

# Build and install yay
echo "Building and installing yay..."
makepkg -si --noconfirm

# Clean up
cd ..
rm -rf /opt/yay

# Verify yay installation
echo "Verifying yay installation..."
if command -v yay &> /dev/null
then
    echo "yay was installed successfully!"
else
    echo "There was an error installing yay."
fi
