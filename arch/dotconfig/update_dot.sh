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
# Main script execution
# Create backup if needed
backup_config

# Replace contents of ~/.config/hypr with contents

rm -rf ~/.config/hypr/*
cp -r ~/a15/arch/dotconfig/hypr/* ~/.config/hypr/*
echo "Configuration replaced in ~/.config/hypr"
