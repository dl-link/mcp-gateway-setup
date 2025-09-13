# Changelog

All notable changes to the MCP Gateway Setup Scripts will be documented in this file.

## [2.0.0] - 2024-09-14

### Added
- **Linux Distribution Support**: Comprehensive support for Ubuntu/Debian, RHEL/CentOS/Fedora, and Arch Linux
- **Automatic Package Management**: Script now detects Linux distribution and installs required packages
- **python3-venv Fix**: Automatically installs python3-venv package on Debian/Ubuntu systems
- **Cross-Platform Compatibility**: Enhanced error handling and fallback mechanisms for different environments

### Fixed
- **Virtual Environment Creation**: Resolves `ModuleNotFoundError: No module named 'venv'` on Linux systems
- **Dependency Detection**: Better detection and installation of system-level dependencies
- **Package Manager Detection**: Automatic detection of apt, yum, dnf, and pacman package managers

### Changed
- **Enhanced Error Messages**: More descriptive error messages with specific installation commands
- **Improved Documentation**: Updated README with Linux-specific troubleshooting and requirements

### Technical Details
- Added `detect_linux_distro()` function for distribution detection
- Added `install_system_dependencies()` function for package management
- Enhanced `setup_virtual_environment()` with retry logic and better error handling
- Improved Python version detection across different Linux distributions

## [1.0.0] - 2024-09-14

### Added
- Initial release with macOS support
- Complete MCP Gateway setup automation
- Virtual environment management
- Server lifecycle management (start/stop/restart/status)
- Development utilities and helper functions
- GitHub repository setup with comprehensive documentation

