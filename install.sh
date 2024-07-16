#!/bin/bash

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check for Docker installation
if ! command_exists docker; then
    echo "Docker is not installed. Please install Docker from https://www.docker.com/products/docker-desktop/ for Mac or follow https://docs.docker.com/engine/install/ubuntu/ for Linux."
    exit 1
fi

# Check for Python3 installation
if ! command_exists python3; then
    echo "Python3 is not installed. Please install Python3 from https://www.python.org/downloads/ for Mac or run 'sudo apt install python3' for Linux."
    exit 1
fi

# Clone the Kobo-install repository
echo "Cloning the Kobo-install repository..."
cd ~ || {
    echo "Failed to enter home directory"
    exit 1
}

git clone https://github.com/kobotoolbox/kobo-install.git

# Navigate into the project directory
cd kobo-install || {
    echo "Failed to enter kobo-install directory"
    exit 1
}

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
