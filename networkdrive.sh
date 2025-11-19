#!/bin/bash

# Colors for CLI
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

clear
echo -e "${BLUE}═══════════════════════════════${NC}"
echo -e "${BLUE}   Network Drive Manager${NC}"
echo -e "${BLUE}═══════════════════════════════${NC}"
echo ""

# Function to mount network drive
mount_network_drive() {
    echo -e "${YELLOW}Mounting network drive...${NC}"
    echo ""
    
    # Ask for network path
    echo -e "${BLUE}Enter network path:${NC}"
    read -p "IP Address (e.g. 192.168.13.16): " ip_address
    
    if [ -z "$ip_address" ]; then
        echo -e "${RED}✗ IP address is required!${NC}"
        return
    fi
    
    echo ""
    echo -e "${BLUE}ℹ Info:${NC} The share is the shared folder on the server."
    echo -e "  Examples:"
    echo -e "  - ${GREEN}ntfs${NC}           → Mounts the share 'ntfs'"
    echo -e "  - ${GREEN}data${NC}           → Mounts the share 'data'"
    echo -e "  - ${GREEN}ntfs/backup${NC}    → Mounts only the subfolder 'backup' from share 'ntfs'"
    echo ""
    read -p "Share/Folder: " share_path
    
    if [ -z "$share_path" ]; then
        echo -e "${RED}✗ Share/Folder is required!${NC}"
        return
    fi
    
    # Compose network path
    NETWORK_PATH="//$ip_address/$share_path"
    
    # Extract mount point name from share path
    # Takes only the first part before "/"
    SHARE_NAME=$(echo "$share_path" | cut -d'/' -f1)
    MOUNT_POINT="$HOME/$SHARE_NAME"
    
    echo ""
    echo -e "Using network path: ${GREEN}$NETWORK_PATH${NC}"
    echo -e "Mount point: ${GREEN}$MOUNT_POINT${NC}"
    echo ""
    
    # Create mount point if it doesn't exist
    if [ ! -d "$MOUNT_POINT" ]; then
        mkdir -p "$MOUNT_POINT"
        echo -e "${GREEN}✓${NC} Mount point created: $MOUNT_POINT"
    fi
    
    # Check if already mounted
    if mountpoint -q "$MOUNT_POINT"; then
        echo -e "${YELLOW}⚠${NC} A network drive is already mounted at this mount point!"
        echo -e "   Mount point: $MOUNT_POINT"
        echo -e "   Please unmount first (Option 2) before mounting a new one."
        return
    fi
    
    # Ask for username
    echo -e "${BLUE}Credentials:${NC}"
    read -p "Username: " username
    
    if [ -z "$username" ]; then
        username="guest"
        echo -e "${YELLOW}⚠${NC} Using 'guest' as username"
    fi
    
    # Ask for password
    read -s -p "Password (Enter for no password): " password
    echo ""
    
    # Execute mount command
    if [ -z "$password" ]; then
        # Without password
        sudo mount -t cifs "$NETWORK_PATH" "$MOUNT_POINT" -o username="$username",password=,uid=$(id -u),gid=$(id -g),iocharset=utf8
    else
        # With password
        sudo mount -t cifs "$NETWORK_PATH" "$MOUNT_POINT" -o username="$username",password="$password",uid=$(id -u),gid=$(id -g),iocharset=utf8
    fi
    
    # Check if successful
    if [ $? -eq 0 ]; then
        echo ""
        echo -e "${GREEN}✓ Network drive successfully mounted!${NC}"
        echo -e "   Path: ${GREEN}$MOUNT_POINT${NC}"
        echo ""
        echo -e "Open with: ${BLUE}nautilus $MOUNT_POINT${NC} or ${BLUE}cd $MOUNT_POINT${NC}"
    else
        echo ""
        echo -e "${RED}✗ Error mounting network drive!${NC}"
        echo -e "   Possible causes:"
        echo -e "   - Wrong credentials"
        echo -e "   - Network connection not available"
        echo -e "   - cifs-utils not installed (sudo apt install cifs-utils)"
    fi
}

# Function to unmount network drive
unmount_network_drive() {
    echo -e "${YELLOW}Unmounting network drive...${NC}"
    echo ""
    
    # List all mounted CIFS network drives in home directory
    echo -e "${BLUE}Mounted network drives:${NC}"
    MOUNTED=$(mount | grep "type cifs" | grep "$HOME" | awk '{print $3}')
    
    if [ -z "$MOUNTED" ]; then
        echo -e "${YELLOW}⚠${NC} No mounted network drives found!"
        return
    fi
    
    echo "$MOUNTED" | nl -w2 -s'. '
    echo ""
    
    read -p "Which drive would you like to unmount? (Enter name, e.g. 'ntfs'): " share_name
    
    if [ -z "$share_name" ]; then
        echo -e "${RED}✗ No name specified!${NC}"
        return
    fi
    
    MOUNT_POINT="$HOME/$share_name"
    
    # Check if mounted
    if ! mountpoint -q "$MOUNT_POINT"; then
        echo -e "${YELLOW}⚠${NC} '$share_name' is not mounted!"
        echo -e "   Path: $MOUNT_POINT"
        return
    fi
    
    # Execute unmount
    sudo umount "$MOUNT_POINT"
    
    # Check if successful
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Network drive successfully unmounted!${NC}"
        
        # Optional: Delete mount point
        read -p "Delete mount point directory '$share_name'? (y/n): " delete_dir
        if [ "$delete_dir" = "y" ] || [ "$delete_dir" = "Y" ]; then
            rmdir "$MOUNT_POINT" 2>/dev/null
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}✓${NC} Mount point deleted"
            else
                echo -e "${YELLOW}⚠${NC} Directory could not be deleted (not empty?)"
            fi
        fi
    else
        echo -e "${RED}✗ Error unmounting network drive!${NC}"
        echo -e "   The drive may still be in use."
    fi
}

# Function to show status
show_status() {
    echo -e "${BLUE}Status of all network drives:${NC}"
    echo ""
    
    # Find all mounted CIFS network drives in home directory
    MOUNTED=$(mount | grep "type cifs" | grep "$HOME")
    
    if [ -n "$MOUNTED" ]; then
        echo -e "  ${GREEN}Mounted network drives:${NC}"
        echo ""
        echo "$MOUNTED" | while read line; do
            NETWORK_PATH=$(echo "$line" | awk '{print $1}')
            MOUNT_PT=$(echo "$line" | awk '{print $3}')
            MOUNT_NAME=$(basename "$MOUNT_PT")
            
            echo -e "  📁 ${GREEN}$MOUNT_NAME${NC}"
            echo -e "     Network path: $NETWORK_PATH"
            echo -e "     Mount point: $MOUNT_PT"
            echo -e "     $(df -h "$MOUNT_PT" 2>/dev/null | tail -n 1 | awk '{print "Size: "$2", Used: "$3", Available: "$4", Usage: "$5}')"
            echo ""
        done
    else
        echo -e "  ${YELLOW}No network drives mounted${NC}"
        echo ""
    fi
}

# Main menu
show_status

echo -e "${BLUE}What would you like to do?${NC}"
echo ""
echo -e "  ${GREEN}1${NC} - Mount network drive"
echo -e "  ${RED}2${NC} - Unmount network drive"
echo -e "  ${BLUE}3${NC} - Show status"
echo -e "  ${YELLOW}4${NC} - Exit"
echo ""
read -p "Your choice [1-4]: " choice

case $choice in
    1)
        echo ""
        mount_network_drive
        ;;
    2)
        echo ""
        unmount_network_drive
        ;;
    3)
        echo ""
        show_status
        ;;
    4)
        echo -e "${BLUE}Goodbye!${NC}"
        exit 0
        ;;
    *)
        echo -e "${RED}✗ Invalid input!${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${BLUE}═══════════════════════════════════════════${NC}"