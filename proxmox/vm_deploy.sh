#!/bin/bash

# Configuration variables
MEMORY=2048            # Memory in MB
DISK_SIZE=32G          # Disk size
BRIDGE="vmbr0"         # Network bridge
CORES=2                # Number of CPU cores
STORAGE="local-zfs"    # Storage location

# URLs for cloud images
ALMALINUX_9_URL="https://repo.almalinux.org/almalinux/9/cloud/x86_64/images/AlmaLinux-9-GenericCloud-latest.x86_64.qcow2"
ALMALINUX_8_URL="https://repo.almalinux.org/almalinux/8/cloud/x86_64/images/AlmaLinux-8-GenericCloud-latest.x86_64.qcow2"
UBUNTU_2204_URL="https://cloud-images.ubuntu.com/releases/jammy/release/ubuntu-22.04-server-cloudimg-amd64.img"
UBUNTU_2404_URL="https://cloud-images.ubuntu.com/releases/lunar/release/ubuntu-24.04-server-cloudimg-amd64.img"

# Get user inputs for the VM type, VLAN ID, IP address, and gateway
read -p "Enter VM type (1 for AlmaLinux 9, 2 for AlmaLinux 8, 3 for Ubuntu 22.04, 4 for Ubuntu 24.04): " VM_TYPE
read -p "Enter VM ID: " VMID
read -p "Enter VM Name: " VM_NAME
read -p "Enter VLAN ID: " VLAN

# Determine the URL and configuration based on the VM type
if [ "$VM_TYPE" -eq 1 ]; then
    IMAGE_URL=$ALMALINUX_9_URL
    IMAGE_EXT="qcow2"
elif [ "$VM_TYPE" -eq 2 ]; then
    IMAGE_URL=$ALMALINUX_8_URL
    IMAGE_EXT="qcow2"
elif [ "$VM_TYPE" -eq 3 ]; then
    IMAGE_URL=$UBUNTU_2204_URL
    IMAGE_EXT="img"
elif [ "$VM_TYPE" -eq 4 ]; then
    IMAGE_URL=$UBUNTU_2404_URL
    IMAGE_EXT="img"
else
    echo "Invalid VM type selected. Exiting."
    exit 1
fi

# Ensure the template directory exists
TEMPLATE_DIR="/var/lib/vz/template/images"
if [ ! -d "$TEMPLATE_DIR" ]; then
    echo "Template directory does not exist. Creating it..."
    mkdir -p "$TEMPLATE_DIR"
fi

# Download the cloud image
echo "Downloading cloud image..."
wget -O ${TEMPLATE_DIR}/${VM_NAME}.${IMAGE_EXT} $IMAGE_URL
if [ $? -ne 0 ]; then
    echo "Failed to download the cloud image. Exiting."
    exit 1
fi

# Create Proxmox VM from the downloaded image
echo "Creating VM from cloud image..."
qm create $VMID --name $VM_NAME --memory $MEMORY --net0 virtio,bridge=$BRIDGE,tag=$VLAN --ostype l26 --cores $CORES
if [ $? -ne 0 ]; then
    echo "Failed to create VM. Exiting."
    exit 1
fi

# Import the disk
echo "Importing disk..."
qm importdisk $VMID ${TEMPLATE_DIR}/${VM_NAME}.${IMAGE_EXT} $STORAGE
if [ $? -ne 0 ]; then
    echo "Failed to import disk. Exiting."
    exit 1
fi

# Configure the VM
echo "Configuring VM..."
qm set $VMID --scsihw virtio-scsi-pci --scsi0 $STORAGE:vm-$VMID-disk-0
qm set $VMID --boot c --bootdisk scsi0
qm set $VMID --ide2 $STORAGE:cloudinit
qm set $VMID --serial0 socket --vga serial0
qm set $VMID --agent enabled=1
if [ $? -ne 0 ]; then
    echo "Failed to configure VM. Exiting."
    exit 1
fi

# Resize the disk
echo "Resizing disk..."
qm resize $VMID scsi0 $DISK_SIZE
if [ $? -ne 0 ]; then
    echo "Failed to resize disk. Exiting."
    exit 1
fi

# Cleanup
echo "Cleaning up..."
rm -rf ${TEMPLATE_DIR}/${VM_NAME}.${IMAGE_EXT}
if [ $? -ne 0 ]; then
    echo "Failed to clean up temporary files."
fi

# Completion message
echo "VM $VM_NAME with ID $VMID has been created with VLAN $VLAN."
