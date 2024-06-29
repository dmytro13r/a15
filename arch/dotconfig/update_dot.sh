#!/bin/bash

# Function to create a backup if requested by the user
backup_config() {
    read -p "Do you want to make a backup of the current configuration? (y/n): " backup_choice
    if [ "$backup_choice" == "y" ]; then
        backup_dir=~/backups/$(date +%Y-%m-%d)/$(date +%s)

        # Create backup directories with timestamps if they do not exist
        mkdir -p "$backup_dir/hypr"
        mkdir -p "$backup_dir/waybar"
        mkdir -p "$backup_dir/swaylock"
        mkdir -p "$backup_dir/swaync"
        mkdir -p "$backup_dir/wlogout"

        # Check if directories were created successfully
        if [ ! -d "$backup_dir/hypr" ]; then
            echo "Failed to create backup directory: $backup_dir/hypr"
            exit 1
        fi
        if [ ! -d "$backup_dir/waybar" ]; then
            echo "Failed to create backup directory: $backup_dir/waybar"
            exit 1
        fi
        if [ ! -d "$backup_dir/swaylock" ]; then
            echo "Failed to create backup directory: $backup_dir/swaylock"
            exit 1
        fi
        if [ ! -d "$backup_dir/swaync" ]; then
            echo "Failed to create backup directory: $backup_dir/swaync"
            exit 1
        fi
        if [ ! -d "$backup_dir/wlogout" ]; then
            echo "Failed to create backup directory: $backup_dir/wlogout"
            exit 1
        fi

        # Backup hypr directory
        cp -r ~/.config/hypr/* "$backup_dir/hypr/"
        echo "Backup created for hypr directory at $backup_dir/hypr"

        # Backup waybar directory
        cp -r ~/.config/waybar/* "$backup_dir/waybar/"
        echo "Backup created for waybar directory at $backup_dir/waybar"

        # Backup swaylock directory
        cp -r ~/.config/swaylock/* "$backup_dir/swaylock/"
        echo "Backup created for swaylock directory at $backup_dir/swaylock"

        # Backup swaync directory
        cp -r ~/.config/swaync/* "$backup_dir/swaync/"
        echo "Backup created for swaync directory at $backup_dir/swaync"

        # Backup wlogout directory
        cp -r ~/.config/wlogout/* "$backup_dir/wlogout/"
        echo "Backup created for wlogout directory at $backup_dir/wlogout"
    fi
}

# Main script execution
# Create backup if needed
backup_config

# Replace contents of ~/.config/hypr with contents from ~/a15/arch/dotconfig/hypr
rm -rf ~/.config/hypr/*
cp -r ~/a15/arch/dotconfig/hypr/* ~/.config/hypr/
echo "Configuration replaced in ~/.config/hypr"

# Replace contents of ~/.config/waybar with contents from ~/a15/arch/dotconfig/waybar
rm -rf ~/.config/waybar/*
cp -r ~/a15/arch/dotconfig/waybar/* ~/.config/waybar/
echo "Configuration replaced in ~/.config/waybar"

# Replace contents of ~/.config/swaylock with contents from ~/a15/arch/dotconfig/swaylock
rm -rf ~/.config/swaylock/*
cp -r ~/a15/arch/dotconfig/swaylock/* ~/.config/swaylock/
echo "Configuration replaced in ~/.config/swaylock"

# Replace contents of ~/.config/swaync with contents from ~/a15/arch/dotconfig/swaync
rm -rf ~/.config/swaync/*
cp -r ~/a15/arch/dotconfig/swaync/* ~/.config/swaync/
echo "Configuration replaced in ~/.config/swaync"

# Replace contents of ~/.config/wlogout with contents from ~/a15/arch/dotconfig/wlogout
rm -rf ~/.config/wlogout/*
cp -r ~/a15/arch/dotconfig/wlogout/* ~/.config/wlogout/
echo "Configuration replaced in ~/.config/wlogout"

pkill waybar && hyprctl dispatch exec waybar
echo "Reloaded waybar configuration"