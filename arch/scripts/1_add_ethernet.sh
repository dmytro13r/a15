#!/bin/bash

# Create a network configuration file for Ethernet
echo "Creating network configuration for Ethernet..."
sudo mkdir -p /etc/systemd/network
echo -e '[Match]\nName=en*\n\n[Network]\nDHCP=yes' | sudo tee /etc/systemd/network/20-wired.network

# Enable and start systemd-networkd
echo "Enabling and starting systemd-networkd..."
sudo systemctl enable systemd-networkd.service
sudo systemctl start systemd-networkd.service

# Enable and start systemd-resolved
echo "Enabling and starting systemd-resolved..."
sudo systemctl enable systemd-resolved.service
sudo systemctl start systemd-resolved.service

# Create a symbolic link for /etc/resolv.conf
echo "Setting up resolv.conf for systemd-resolved..."
sudo ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

# Check and display the status of systemd-networkd and systemd-resolved
echo "Checking the status of systemd-networkd..."
systemctl status systemd-networkd.service

echo "Checking the status of systemd-resolved..."
systemctl status systemd-resolved.service

# Display the IP address of the Ethernet interface
echo "Displaying the IP address of the Ethernet interface..."
ip addr show

# Display the DNS resolution status
echo "Checking DNS resolution status..."
systemd-resolve --status

echo "Ethernet setup complete. Please check the output above for any errors."
