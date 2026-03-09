#!/bin/bash
# X11 forwarding setup for GUI applications in WSL2

echo "Setting up X11 forwarding for GUI applications..."

# Install X11 utilities
sudo apt install -y x11-apps xauth

# Add X11 configuration to shell
if ! grep -q "# X11 Display" ~/.zshrc; then
    cat >> ~/.zshrc << 'EOF'

# X11 Display configuration for WSL2
export DISPLAY=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}'):0.0
export LIBGL_ALWAYS_INDIRECT=1

# Function to test X11 forwarding
test-x11() {
    echo "Testing X11 forwarding with xclock..."
    xclock &
    echo "If xclock opens, X11 forwarding is working!"
    echo "Make sure to install an X server on Windows (like VcXsrv, X410, or WSLg)"
}

EOF
fi

# Create .Xauthority file if it doesn't exist
touch ~/.Xauthority

echo "✅ X11 forwarding configured"
echo ""
echo "To use GUI applications:"
echo "1. Install an X server on Windows:"
echo "   • VcXsrv (free): https://sourceforge.net/projects/vcxsrv/"
echo "   • X410 (paid): Microsoft Store"
echo "   • Or use WSLg if you have Windows 11"
echo "2. Configure your X server to allow connections from WSL2"
echo "3. Test with: test-x11"