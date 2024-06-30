#!/bin/bash

# Function to create a backup if requested by the user
backup_config() {
    read -p "Do you want to make a backup of the current configuration? (y/n): " backup_choice
    if [ "$backup_choice" == "y" ]; then
        backup_dir=~/backups/$(date +%Y-%m-%d)/$(date +%s)

        # Create backup directories with timestamps if they do not exist
        mkdir -p "$backup_dir/hypr" "$backup_dir/waybar" "$backup_dir/swaylock" "$backup_dir/swaync" "$backup_dir/wlogout"

        # Check if directories were created successfully
        for dir in hypr waybar swaylock swaync wlogout; do
            if [ ! -d "$backup_dir/$dir" ]; then
                echo "Failed to create backup directory: $backup_dir/$dir"
                exit 1
            fi
        done

        # Backup directories
        for dir in hypr waybar swaylock swaync wlogout; do
            cp -r ~/.config/$dir/* "$backup_dir/$dir/"
            echo "Backup created for $dir directory at $backup_dir/$dir"
        done
    fi
}

# Main script execution
echo "Script started at $(date)"

# Create backup if needed
backup_config

# Replace configurations
for dir in hypr waybar swaylock swaync wlogout; do
    rm -rf ~/.config/$dir/*
    cp -r ~/a15/arch/dotconfig/$dir/* ~/.config/$dir/
    echo "Configuration replaced in ~/.config/$dir"
done

# Restart Waybar and related services
echo "Restarting Waybar..."
pkill waybar
sleep 1  # Give some time for Waybar to be killed
waybar &

# Check if Waybar started successfully
sleep 2
if pgrep waybar > /dev/null; then
    echo "Waybar started successfully"
else
    echo "Failed to start Waybar"
    exit 1
fi

echo "Reloading swaync configuration..."
swaync-client -R

echo "Script completed at $(date)"
