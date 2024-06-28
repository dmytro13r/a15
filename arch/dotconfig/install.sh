#!/bin/bash

# Function to create a backup if requested by the user
backup_config() {
    read -p "Do you want to make a backup of the current configuration? (y/n): " backup_choice
    if [ "$backup_choice" == "y" ]; then
        backup_dir=~/backups/hypr/$(date +%Y-%m-%d)/hypr_$(date +%s)
        mkdir -p "$backup_dir"
        cp -r ~/.config/hypr/* "$backup_dir"
        echo "Backup created at $backup_dir"
    fi
}

# Function to reload Hyprland if requested by the user
reload_hyprland() {
    read -p "Do you want to reload Hyprland? (y/n): " reload_choice
    if [ "$reload_choice" == "y" ]; then
        hyprctl reload
        echo "Hyprland reloaded"
    else
        echo "Script finished without reloading Hyprland"
    fi
}

# Main script execution
# Create backup if needed
backup_config

# Replace contents of ~/.config/hypr with contents of hypr directory
rm -rf ~/.config/hypr/*
cp -r hypr/* ~/.config/hypr/
echo "Configuration replaced in ~/.config/hypr"
