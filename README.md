# 🐍 MCP Gateway Setup Scripts

> One-command setup for [IBM MCP Context Forge](https://github.com/IBM/mcp-context-forge) - works on macOS and Linux

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Shell](https://img.shields.io/badge/Shell-Bash-green.svg)](https://www.gnu.org/software/bash/)
[![Python](https://img.shields.io/badge/Python-3.11%2B-blue.svg)](https://www.python.org/)

## 🚀 **One-Command Installation**

```bash
wget https://raw.githubusercontent.com/dl-link/mcp-gateway-setup/main/setup-mcp-gateway.sh
chmod +x setup-mcp-gateway.sh
./setup-mcp-gateway.sh setup
```

**That's it!** 🎉 The script automatically handles everything:

✅ **Python 3.11+ detection** and virtual environment setup  
✅ **Linux package dependencies** (python3-venv, dev tools)  
✅ **UV package manager** installation and configuration  
✅ **MCP Gateway dependencies** and database setup  
✅ **Secure password generation** for admin account  
✅ **Server startup** and health verification  

## 🌍 **Platform Support**

- **macOS** (any recent version)
- **Linux**: Ubuntu/Debian, RHEL/CentOS/Fedora, Arch Linux
- **Docker/Containers**: Works in RAGFlow and other containerized environments

## 📋 **Server Management**

After installation, you can manage the server with these commands:

```bash
./setup-mcp-gateway.sh start        # Start server
./setup-mcp-gateway.sh stop         # Stop server
./setup-mcp-gateway.sh restart      # Restart server
./setup-mcp-gateway.sh status       # Show status and URLs
./setup-mcp-gateway.sh credentials  # Show login credentials
./setup-mcp-gateway.sh clean        # Clean environment
./setup-mcp-gateway.sh help         # Show help
```

## 🌐 **Access Your Server**

Once running, access your MCP Gateway at:

- **🌐 Main Server**: http://localhost:4444
- **🔧 Admin UI**: http://localhost:4444 (login: admin/auto-generated-password)
- **📚 API Documentation**: http://localhost:4444/docs
- **❤️ Health Check**: http://localhost:4444/health

> 🔑 **The admin password is auto-generated during setup for security.** Check the console output or run `./setup-mcp-gateway.sh credentials` to see your login details.

## 🔧 **What This Solves**

✅ **Python Version Issues**: Automatically detects and uses Python 3.11+ (avoids 3.10 compatibility issues)  
✅ **Linux Dependencies**: Installs `python3-venv`, `python3-dev`, and build tools automatically  
✅ **Virtual Environment**: Creates properly isolated environments with correct Python version  
✅ **UV Package Manager**: Fast, reliable package installation  
✅ **Security**: Auto-generates secure admin passwords and JWT secrets  
✅ **Server Management**: Background process handling with proper PID tracking  
✅ **Configuration**: Automated .env setup with sensible defaults  

## 🔍 **Troubleshooting**

**Server Won't Start?**
```bash
./setup-mcp-gateway.sh status    # Check status
./setup-mcp-gateway.sh clean     # Clean and retry
./setup-mcp-gateway.sh setup     # Full setup again
```

**Port Already in Use?**
```bash
# Edit .env file to change port
echo "PORT=8001" >> .env
./setup-mcp-gateway.sh restart
```

## � **Additional Files**

This repository also includes:
- `dev-utils.sh` - Development utilities and helper functions
- `examples/` - Production configuration examples
- `CHANGELOG.md` - Version history and updates
- `LINUX-FIX-SUMMARY.md` - Linux compatibility documentation

## 🤝 **Contributing**

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`  
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push to branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

## 📝 **License**

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Made with ❤️ for the MCP Community**

[⭐ Star this repo](https://github.com/dl-link/mcp-gateway-setup) if it helped you!

