#!/bin/bash

# Configuration variables
MEMORY=2048            # Memory in MB
DISK_SIZE=32G          # Disk size
BRIDGE="vmbr0"         # Network bridge
CORES=2                # Number of CPU cores
STORAGE="local-zfs"    # Storage location

# URLs for cloud images
ALMALINUX_9_URL="https://repo.almalinux.org/almalinux/9/cloud/x86_64/images/AlmaLinux-9-GenericCloud-latest.x86_64.qcow2 "
ALMALINUX_8_URL="https://repo.almalinux.org/almalinux/8/cloud/x86_64/images/AlmaLinux-8-GenericCloud-latest.x86_64.qcow2 "
UBUNTU_2204_URL="https://cloud-images.ubuntu.com/releases/jammy/release/ubuntu-22.04-server-cloudimg-amd64.img"

# Get user inputs for the VM type, VLAN ID, IP address, and gateway
read -p "Enter VM type (1 for AlmaLinux 9, 2 for AlmaLinux 8, 3 for Ubuntu 22.04): " VM_TYPE
read -p "Enter VM ID: " VMID
read -p "Enter VM Name: " VM_NAME
read -p "Enter VLAN ID: " VLAN

# Determine the URL and configuration based on the VM type
if [ "$VM_TYPE" -eq 1 ]; then
    IMAGE_URL=$ALMALINUX_9_URL
    CIUSER="almalinux"
elif [ "$VM_TYPE" -eq 2 ]; then
    IMAGE_URL=$ALMALINUX_8_URL
    CIUSER="almalinux"
elif [ "$VM_TYPE" -eq 3 ]; then
    IMAGE_URL=$UBUNTU_2204_URL
    CIUSER="ubuntu"
else
    echo "Invalid VM type selected. Exiting."
    exit 1
fi

# Download the cloud image
echo "Downloading cloud image..."
wget -O /var/lib/vz/template/qcow2/${VM_NAME}.qcow2 $IMAGE_URL

# Create Proxmox VM from the downloaded image
echo "Creating VM from cloud image..."
qm create $VMID --name $VM_NAME --memory $MEMORY --net0 virtio,bridge=$BRIDGE,tag=$VLAN --ostype l26 --cores $CORES

# Import the disk
qm importdisk $VMID /var/lib/vz/template/qcow2/${VM_NAME}.qcow2 $STORAGE

# Configure the VM
qm set $VMID --scsihw virtio-scsi-pci --scsi0 $STORAGE:vm-$VMID-disk-0
qm set $VMID --boot c --bootdisk scsi0
qm set $VMID --ide2 $STORAGE:cloudinit
qm set $VMID --serial0 socket --vga serial0
qm set $VMID --agent enabled=1

# Resize the disk
qm resize $VMID virtio0 $DISK_SIZE

echo "Cleanup"
rm -rf /var/lib/vz/template/qcow2/${VM_NAME}.qcow2


echo "VM $VM_NAME with ID $VMID has been created with VLAN $VLAN."
