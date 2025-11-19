# Network Drive Manager 🗂️

A user-friendly shell script for Ubuntu/Linux to easily mount and unmount network drives (SMB/CIFS) via the command line.

## 📋 Table of Contents

- [Features](#-features)
- [Requirements](#-requirements)
- [Installation](#-installation)
- [Usage](#-usage)
- [Examples](#-examples)
- [Common Issues](#-common-issues)
- [License](#-license)

## ✨ Features

- 🎨 **Colorful CLI Interface** - Clear and modern menu
- 🔌 **Flexible Network Paths** - Freely configurable IP address and share
- 📁 **Automatic Naming** - Mount points are named after the share name
- 🔄 **Multiple Drives** - Mount multiple network drives simultaneously
- 📊 **Status Overview** - Shows all mounted drives with details
- 🔒 **Secure Password Input** - Passwords are entered hidden
- 🧹 **Clean Removal** - Optional deletion of mount points when unmounting

## 🔧 Requirements

- **Operating System**: Ubuntu 22.04 LTS or higher (also works with other Debian-based distributions)
- **Packages**: `cifs-utils` must be installed
- **Permissions**: sudo privileges for mount operations

## 📦 Installation

### 1. Clone the repository

```bash
git clone https://github.com/your-username/network-drive-manager.git
cd network-drive-manager
```

### 2. Install dependencies

```bash
sudo apt update
sudo apt install cifs-utils
```

### 3. Make script executable

```bash
chmod +x netzlaufwerk.sh
```

## 🚀 Usage

### Start the script

```bash
./netzlaufwerk.sh
```

### Main Menu

After starting, the main menu appears with the following options:

```
═══════════════════════════════════════════
   Network Drive Manager
═══════════════════════════════════════════

Status of all network drives:
  [Status overview is displayed here]

What would you like to do?

  1 - Mount network drive
  2 - Unmount network drive
  3 - Show status
  4 - Exit

Your choice [1-4]:
```

### Option 1: Mount Network Drive

The script asks for the following information:

1. **IP Address** of the server (e.g., `192.168.13.16`)
2. **Share/Folder** - The shared folder on the server
   - Example: `ntfs` → Mounts the complete share
   - Example: `data` → Mounts another share
   - Example: `ntfs/backup` → Mounts only a subfolder
3. **Username** for authentication
4. **Password** (optional, entered hidden)

**Mount Point**: The drive is automatically mounted under `~/ShareName`.

### Option 2: Unmount Network Drive

- Shows all currently mounted network drives
- Asks for the name of the drive to be removed
- Optional: Deletes the mount point directory

### Option 3: Show Status

Shows detailed information about all mounted network drives:
- Drive name
- Network path
- Mount point
- Storage space (size, used, available, utilization)

### Option 4: Exit

Exits the script.

## 📚 Examples

### Example 1: Simple Share Mounting

```
IP Address: 192.168.1.100
Share/Folder: data

Result:
- Network path: //192.168.1.100/data
- Mount point: ~/data
- Access: cd ~/data
```

### Example 2: Mounting a Subfolder

```
IP Address: 192.168.1.100
Share/Folder: nas/backup/2024

Result:
- Network path: //192.168.1.100/nas/backup/2024
- Mount point: ~/nas
- Access: cd ~/nas
```

### Example 3: Multiple Drives Simultaneously

```
1st Mount:
   IP: 192.168.1.100
   Share: ntfs
   → Mount point: ~/ntfs

2nd Mount:
   IP: 192.168.1.100
   Share: backup
   → Mount point: ~/backup

Both drives are now available simultaneously!
```

### Example 4: Guest Access Without Password

```
IP Address: 192.168.1.100
Share/Folder: public
Username: guest
Password: [Press Enter for no password]

Result: Connection as guest user
```

## 🛠️ Common Issues

### Problem: "mount error(13): Permission denied"

**Solution**: Wrong credentials or no permission on the server.
- Check username and password
- Ensure the user has access to the share

### Problem: "mount error(115): Operation now in progress"

**Solution**: Server not reachable.
- Check the IP address
- Test the connection: `ping 192.168.1.100`
- Check firewall settings

### Problem: "mount: /home/user/ntfs: bad option"

**Solution**: `cifs-utils` is not installed.
```bash
sudo apt install cifs-utils
```

### Problem: "Device or resource busy"

**Solution**: The drive is still in use.
- Close all programs accessing the drive
- Check with: `lsof | grep /home/user/ntfs`
- Terminate processes or restart the system

### Problem: Special characters not displayed correctly

**Solution**: The script already uses `iocharset=utf8`. If problems persist:
```bash
# Manually mount with specific charset
sudo mount -t cifs //server/share /mount/point -o username=user,iocharset=utf8,codepage=850
```

## 🔐 Security Notes

- **Passwords**: Only kept temporarily in memory and not saved
- **sudo**: Required for mount operations, only use trusted sources
- **Network**: Ensure you are on a trusted network
- **Credentials**: Don't use administrator accounts if not necessary

## 📝 Technical Details

### Mount Options

The script uses the following mount options:
- `username`: Username for authentication
- `password`: Password (optional)
- `uid=$(id -u)`: Sets the owner to the current user
- `gid=$(id -g)`: Sets the group to that of the current user
- `iocharset=utf8`: Correct display of special characters

### Directory Structure

```
~/
├── ntfs/           # Mount point for share "ntfs"
├── backup/         # Mount point for share "backup"
└── data/           # Mount point for share "data"
```

## 🤝 Contributing

Contributions are welcome! 

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👤 Author

Created with ❤️ from RootGeek for the Linux community

## 🙏 Acknowledgments

- Inspired by the Ubuntu/Linux community
- Thanks to all testers and contributors

---

**Note**: This script was developed and tested for Ubuntu 22.04 LTS, but should work on most Debian-based distributions.

## 📞 Support

For questions or problems:
- Open an [Issue](https://github.com/your-username/network-drive-manager/issues)
- Check the [FAQ](#-common-issues)

---

**Happy Mounting! 🚀**
