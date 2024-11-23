#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color
YELLOW='\033[1;33m'
CYAN='\033[0;36m'

# Function to display banner
print_banner() {
    clear
    echo -e "${CYAN}"
    echo '███╗   ███╗██╗   ██╗██╗  ████████╗██╗██████╗ ██╗     ███████╗'
    echo '████╗ ████║██║   ██║██║  ╚══██╔══╝██║██╔══██╗██║     ██╔════╝'
    echo '██╔████╔██║██║   ██║██║     ██║   ██║██████╔╝██║     █████╗  '
    echo '██║╚██╔╝██║██║   ██║██║     ██║   ██║██╔═══╝ ██║     ██╔══╝  '
    echo '██║ ╚═╝ ██║╚██████╔╝███████╗██║   ██║██║     ███████╗███████╗'
    echo '╚═╝     ╚═╝ ╚═════╝ ╚══════╝╚═╝   ╚═╝╚═╝     ╚══════╝╚══════╝'
    echo -e "${NC}"
    echo -e "${GREEN}================================================${NC}"
    echo -e "         Multiple Node Auto Installer Script"
    echo -e "${YELLOW}        Author: https://github.com/Galkurta${NC}"
    echo -e "${GREEN}================================================${NC}"
    echo ""
}

# Function to show progress
show_progress() {
    echo -e "${YELLOW}[+] $1...${NC}"
}

# Function to check errors
check_error() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[✓] $1 successful${NC}"
    else
        echo -e "${RED}[×] $1 failed${NC}"
        exit 1
    fi
}

# Function to validate input
validate_input() {
    if [[ -z "$1" ]]; then
        echo -e "${RED}[×] Input cannot be empty${NC}"
        exit 1
    fi
}

# Main Installation
print_banner

# Step 1: User confirmation
echo -e "This process will:"
echo "1. Update system"
echo "2. Install prerequisites"
echo "3. Install Multiple Node Client"
echo "4. Configure node"
echo ""
read -p "Continue installation? (y/n): " confirm
if [[ "$confirm" != "y" ]]; then
    exit 1
fi

# Step 2: Update and Install Prerequisites
show_progress "Updating system and installing prerequisites"
sudo apt update && sudo apt upgrade -y
check_error "System update"

show_progress "Installing prerequisites"
sudo apt install -y curl tar wget aria2 clang pkg-config libssl-dev jq build-essential
check_error "Prerequisites installation"

# Step 3: Install Multiple Node Client
show_progress "Installing Multiple Node Client"
wget https://cdn.app.multiple.cc/client/linux/x64/multipleforlinux.tar
check_error "Download Multiple Node Client"

tar -xvf multipleforlinux.tar
check_error "Extract Multiple Node Client"

chmod +x /root/multipleforlinux/multiple-cli
chmod +x /root/multipleforlinux/multiple-node
check_error "Set permissions"

PATH=$PATH:multipleforlinux
source /etc/profile

# Step 4: Node Configuration
print_banner
echo -e "${YELLOW}Node Configuration${NC}"
echo "Please visit: https://www.app.multiple.cc/#/setup to get your identification code"
echo ""

read -p "Enter identification code: " identifier
validate_input "$identifier"

read -p "Enter PIN (minimum 6 digits): " pin
validate_input "$pin"
if [[ ${#pin} -lt 6 ]]; then
    echo -e "${RED}[×] PIN must be at least 6 digits${NC}"
    exit 1
fi

read -p "Enter download bandwidth (Mbps) [100]: " bandwidth_down
bandwidth_down=${bandwidth_down:-100}

read -p "Enter upload bandwidth (Mbps) [100]: " bandwidth_up
bandwidth_up=${bandwidth_up:-100}

read -p "Enter storage (GB) [200]: " storage
storage=${storage:-200}

# Step 5: Running Node
show_progress "Starting Multiple Node"
nohup /root/multipleforlinux/multiple-node > output.log 2>&1 &
check_error "Start node service"

show_progress "Binding node"
multiple-cli bind --bandwidth-download "$bandwidth_down" --identifier "$identifier" --pin "$pin" --storage "$storage" --bandwidth-upload "$bandwidth_up"
check_error "Bind node"

# Final
echo ""
echo -e "${GREEN}================================================"
echo "Multiple Node installation completed!"
echo "$================================================${NC}"
echo ""
echo "Available commands:"
echo "- Check status: multiple-cli status"
echo "- View all commands: multiple-cli --help"
echo ""
echo -e "${YELLOW}Node log saved in: output.log${NC}"

# Add donation info
echo -e "${CYAN}================================================"
echo "If you find this script helpful, you can support me at:"
echo "GitHub: https://github.com/Galkurta"
echo "Telegram: https://t.me/galkurtarchive"
echo "$================================================${NC}"