#!/bin/bash

# Docker Installation Script for Debian-based systems (Ubuntu, Kali Linux)
# This script automates the process of setting up the official Docker repository,
# installing Docker Engine, and adding the current user to the 'docker' group.

# -- Configuration -- 
DOCKER_USER=$(whoami)
# Resetting the LSB_RELEASE variable for compatibility with kali

if [ -f /etc/os-release ];
then
    . /etc/os-release
    if [ "$ID" = "kali" ]; then
        DISTRIB_ID="Debian"
        #kali tracks Debian testing/unstable. using 'bookworm' (stable Debian) as a fallback
        VERSION_CODENAME="bookworm"
    elif [ "$ID" = "ubuntu" ]; then
        DISTRIB_ID="Ubuntu"
        # Get the current  release
        VERSION_CODENAME=$(lsb_release -cs)
    else
        echo "Unsupported linux distribution ($ID). Exiting."
        exit 1
    fi
else
    echo "Could not detect distro. Exiting."
fi

echo " -- Docker Engine Installation script -- "
echo "Detected OS: $DISTRIB_ID ($VERSION_CODENAME)"

#update the apt package list and install necessary packages

echo "1. Updating package list and installing prerequisites"
sudo apt update
sudo apt install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# 2. Add Docker's official GPG key
echo "2. Adding Docker's official GPG key..."
sudo install -m 0755 -d /etc/apt/keyrings

# The 'tr' converts Ubuntu to ubuntu or Debian to debian for the download URL
curl -fsSL https://download.docker.com/linux/$(echo "$DISTRIB_ID" | tr '[:upper:]' '[:lower:]')/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

#3. Setting up the Docker repo and adding it to the APT sources
echo "3. Setting up the Docker repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$(echo "$DISTRIB_ID" | tr '[:upper:]' '[:lower:]') \
  $VERSION_CODENAME stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

#4. Install docker engine, CLI,  and containerd
echo "4. Installing Docker Engine Components..."
if command -v docker &>/dev/null; then
    echo "Docker is already installed. Skipping installation step."
else
    echo "Installing Docker Engine components..."
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
fi

#5. Verify the installation
echo "5. Verifying the Docker installation ..."
 sudo docker run hello-world

#6. Add the current user to the 'docker' group to run commands without 'sudo'
echo "6. Adding user '$DOCKER_USER' to the 'docker' group..."
sudo usermod -aG docker "$DOCKER_USER"

echo "----------------------"
echo "Installation Complete"
echo "----------------------"

echo "ACTION REQUIRED: You need to log out and log back in (or run 'newgrp docker') "
echo "for the group changes to take place"
