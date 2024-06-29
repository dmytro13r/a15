#!/bin/bash

# Script for installing Pipewire and removing PulseAudio on Arch Linux
# Integrated into the repository with enhanced logging and modularity

# 💫 https://github.com/dmytro13r/a15 💫 #

# Pipewire and Pipewire Audio Packages
pipewire_packages=(
    pipewire
    wireplumber
    pipewire-audio
    pipewire-alsa
    pipewire-pulse
)

############## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##############

# Set some colors for output messages
YELLOW='\033[1;33m'
RESET='\033[0m'
NOTE='\033[1;34m'
ERROR='\033[1;31m'

# Determine the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1

# Set the name of the log file to include the current date and time
LOG_DIR="$SCRIPT_DIR/Install-Logs"
mkdir -p "$LOG_DIR"
LOG="$LOG_DIR/install-$(date +%Y-%m-%d_%H-%M-%S)_pipewire.log"

# Check for AUR helper (yay or paru)
ISAUR=$(command -v yay || command -v paru)

# Function to install packages
install_package() {
    package=$1
    if sudo pacman -S --noconfirm "$package"; then
        echo "${NOTE} - $package installed successfully" | tee -a "$LOG"
    else
        echo "${ERROR} - $package installation failed" | tee -a "$LOG"
        exit 1
    fi
}

# Removal of PulseAudio
printf "${YELLOW}Removing PulseAudio packages...${RESET}\n" | tee -a "$LOG"
for pulseaudio in pulseaudio pulseaudio-alsa pulseaudio-bluetooth; do
    if sudo pacman -R --noconfirm "$pulseaudio"; then
        echo "${NOTE} - $pulseaudio removed successfully" | tee -a "$LOG"
    else
        echo "${NOTE} - $pulseaudio was not installed or failed to remove" | tee -a "$LOG"
    fi
done

# Disabling PulseAudio services to avoid conflicts
echo "${NOTE}Disabling PulseAudio services...${RESET}" | tee -a "$LOG"
if systemctl --user disable --now pulseaudio.socket pulseaudio.service; then
    echo "${NOTE} - PulseAudio services disabled successfully" | tee -a "$LOG"
else
    echo "${NOTE} - PulseAudio services were not enabled or failed to disable" | tee -a "$LOG"
fi

# Installing Pipewire packages
printf "${NOTE}Installing Pipewire packages...${RESET}\n" | tee -a "$LOG"
for pipewire in "${pipewire_packages[@]}"; do
    install_package "$pipewire"
done

# Activating Pipewire services
printf "${NOTE}Activating Pipewire services...${RESET}\n" | tee -a "$LOG"
if systemctl --user enable --now pipewire.socket pipewire-pulse.socket wireplumber.service pipewire.service; then
    echo "${NOTE} - Pipewire services activated successfully" | tee -a "$LOG"
else
    echo "${ERROR} - Failed to activate Pipewire services" | tee -a "$LOG"
    exit 1
fi

echo "${NOTE}Script execution completed successfully.${RESET}" | tee -a "$LOG"
clear
