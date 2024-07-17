#!/bin/bash

set -e

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

install_docker() {
    echo "Installing Docker..."
    sudo apt-get update
    sudo apt-get install ca-certificates curl -y
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Add the repository to Apt sources:
    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |
        sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
    sudo apt-get update
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

    sudo usermod -aG docker "$USER"
    newgrp docker

    sudo systemctl enable docker.service
    sudo systemctl enable containerd.service
    echo "Docker installed successfully."
}

install_docker_compose() {
    echo "Installing Docker Compose..."
    curl -SL https://github.com/docker/compose/releases/download/v2.28.1/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose

    echo "Docker Compose installed successfully."
}

install_python3() {
    echo "Installing Python3..."
    sudo apt-get update
    sudo apt-get install -y python3 python3-pip python3-venv
    echo "Python3 installed successfully."
}

main() {
    # Check and install Docker if not present
    if ! command_exists docker; then
        install_docker
    else
        echo "Docker is already installed."
    fi

    # Check and install Docker Compose if not present
    if ! command_exists docker-compose; then
        install_docker_compose
    else
        echo "Docker Compose is already installed."
    fi

    # Check and install Python3 if not present
    if ! command_exists python3; then
        install_python3
    else
        echo "Python3 is already installed."
    fi

    # Clone the Kobo-install repository
    echo "Cloning the Kobo-install repository..."
    cd ~ || {
        echo "Failed to enter home directory"
        exit 1
    }

    if [ -d "kobo-install" ]; then
        echo "kobo-install directory already exists. Updating..."
        cd kobo-install
        git pull
    else
        git clone https://github.com/kobotoolbox/kobo-install.git
        cd kobo-install || {
            echo "Failed to enter kobo-install directory"
            exit 1
        }
    fi

    # Create a virtual environment
    echo "Creating a virtual environment..."
    python3 -m venv venv

    # Activate the virtual environment
    echo "Activating the virtual environment..."
    source venv/bin/activate

    # Install netifaces
    echo "Installing netifaces..."
    python3 -m pip install netifaces

    # Run the installer
    echo "Running the installer..."
    python3 run.py

    echo "Kobo Toolbox installation completed successfully."
}

main
