#!/bin/bash

# setup.sh - Script to build and install rpicam-apps on Raspberry Pi 5 (Ubuntu 24.04.3)

# Exit on any error
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting rpicam-apps setup on Raspberry Pi 5 (Ubuntu 24.04.3)...${NC}"

# Update package lists
echo -e "${GREEN}Updating package lists...${NC}"
sudo apt update || { echo -e "${RED}Failed to update package lists. Exiting.${NC}"; exit 1; }

# Install dependencies
echo -e "${GREEN}Installing dependencies...${NC}"
sudo apt install -y clang meson ninja-build pkg-config libyaml-dev python3-yaml python3-ply python3-jinja2 openssl \
    libdw-dev libunwind-dev libudev-dev libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libpython3-dev pybind11-dev \
    libevent-dev libtiff-dev qt6-base-dev qt6-tools-dev-tools liblttng-ust-dev lttng-tools libexif-dev libjpeg-dev \
    libboost-program-options-dev libdrm-dev libavcodec-extra libavcodec-dev libavdevice-dev libpng-dev libpng-tools \
    libepoxy-dev qt5-qmake qtmultimedia5-dev libgtest-dev abi-compliance-checker || \
    { echo -e "${RED}Failed to install dependencies. Exiting.${NC}"; exit 1; }

# Configure camera module
echo -e "${GREEN}Configuring camera module in config.txt...${NC}"
if ! grep -q "dtoverlay=imx219" /boot/firmware/config.txt; then
    echo "dtoverlay=imx219,cam0" | sudo tee -a /boot/firmware/config.txt
    echo "dtoverlay=imx219,cam1" | sudo tee -a /boot/firmware/config.txt
    echo -e "${GREEN}Camera overlays added to config.txt.${NC}"
else
    echo -e "${GREEN}Camera overlays already present in config.txt.${NC}"
fi

# Build and install libcamera
echo -e "${GREEN}Building and installing libcamera...${NC}"
if [ -d "libcamera" ]; then
    rm -rf libcamera
fi
git clone https://github.com/raspberrypi/libcamera.git || { echo -e "${RED}Failed to clone libcamera. Exiting.${NC}"; exit 1; }
cd libcamera
meson setup build --buildtype=release -Dpipelines=rpi/vc4,rpi/pisp -Dipas=rpi/vc4,rpi/pisp -Dv4l2=true -Dgstreamer=enabled \
    -Dtest=false -Dlc-compliance=disabled -Dcam=disabled -Dqcam=disabled -Ddocumentation=disabled -Dpycamera=enabled || \
    { echo -e "${RED}Meson setup failed for libcamera. Exiting.${NC}"; exit 1; }
=ninja -C build || { echo -e "${RED}Ninja build failed for libcamera. Exiting.${NC}"; exit 1; }
sudo ninja -C build install || { echo -e "${RED}Ninja install failed for libcamera. Exiting.${NC}"; exit 1; }
cd ..

# Build and install rpicam-apps
echo -e "${GREEN}Building and installing rpicam-apps...${NC}"
if [ -d "rpicam-apps" ]; then
    rm -rf rpicam-apps
fi
git clone https://github.com/raspberrypi/rpicam-apps.git || { echo -e "${RED}Failed to clone rpicam-apps. Exiting.${NC}"; exit 1; }
cd rpicam-apps
meson setup build -Denable_libav=enabled -Denable_drm=enabled -Denable_egl=enabled -Denable_qt=enabled \
    -Denable_opencv=disabled -Denable_tflite=disabled -Denable_hailo=disabled || \
    { echo -e "${RED}Meson setup failed for rpicam-apps. Exiting.${NC}"; exit 1; }
meson compile -C build || { echo -e "${RED}Meson compile failed for rpicam-apps. Exiting.${NC}"; exit 1; }
sudo meson install -C build || { echo -e "${RED}Meson install failed for rpicam-apps. Exiting.${NC}"; exit 1; }
cd ..

# Reboot to apply changes
echo -e "${GREEN}Setup complete. Rebooting now...${NC}"
sudo reboot now
