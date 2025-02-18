#!/bin/bash

#Updated 2025-02-18

# Get script path
SCRIPT=$(readlink -f "$0")

# Install necessary fonts and libraries
yum install -y xorg-x11-fonts-Type1 xorg-x11-fonts-75dpi libXrender

# Check OS name and version
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS_NAME=$ID
    OS_VERSION=${VERSION_ID%%.*}
else
    echo "Cannot determine the operating system."
    exit 1
fi

# If OS is AlmaLinux 9+ or CloudLinux 9+, install compat-openssl11
if { [ "$OS_NAME" == "almalinux" ] || [ "$OS_NAME" == "cloudlinux" ]; } && [ "$OS_VERSION" -ge 9 ]; then
    yum install -y compat-openssl11
fi

# Download and install wkhtmltopdf
wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox-0.12.6-1.centos8.x86_64.rpm
rpm -i wkhtmltox-0.12.6-1.centos8.x86_64.rpm

echo -e "Installation done \nTesting:"

# Test wkhtmltopdf
wkhtmltopdf https://google.hr google.pdf

echo -e "All done - cleaning \nIvan je najbolji"

# Clean up
rm -f wkhtmltox-0.12.6-1.centos8.x86_64.rpm
rm -f "$SCRIPT"

echo -e "Clean up completed"
