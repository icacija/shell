#!/bin/bash

# Configuration variables
MEMORY=2048            # Memory in MB
DISK_SIZE=32G          # Disk size
BRIDGE="vmbr0"         # Network bridge
CORES=2                # Number of CPU cores
STORAGE="zfs2"    # Storage location

# URLs for cloud images
ALMALINUX_9_URL="https://transfer.oblacno.net/cdn/AlmaLinux-9-GenericCloud-latest.x86_64.qcow2"
ALMALINUX_8_URL="https://transfer.oblacno.net/cdn/AlmaLinux-8-GenericCloud-latest.x86_64.qcow2"
UBUNTU_2204_URL="https://transfer.oblacno.net/cdn/ubuntu-22.04-server-cloudimg-amd64.img"
UBUNTU_2404_URL="https://transfer.oblacno.net/cdn/ubuntu-24.04-server-cloudimg-amd64.img"
DEBIAN_12_URL="https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-generic-amd64.qcow2"  # Definirajte vlastitu lokaciju

# Display menu options
echo "Dostupni tipovi VM-ova:"
echo "1. AlmaLinux 9"
echo "2. AlmaLinux 8"
echo "3. Ubuntu 22.04"
echo "4. Ubuntu 24.04"
echo "5. Debian 12"
echo ""

# Get user inputs for the VM type, VLAN ID, IP address, and gateway
read -p "Unesite tip VM-a (1-5): " VM_TYPE
read -p "Unesite VM ID: " VMID
read -p "Unesite naziv VM-a: " VM_NAME
read -p "Unesite VLAN ID: " VLAN

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
elif [ "$VM_TYPE" -eq 5 ]; then
    IMAGE_URL=$DEBIAN_12_URL
    IMAGE_EXT="qcow2"
else
    echo "Neispravna opcija. Izlazim iz skripte."
    exit 1
fi

# Ensure the template directory exists
TEMPLATE_DIR="/var/lib/vz/template/images"
if [ ! -d "$TEMPLATE_DIR" ]; then
    echo "Template direktorij ne postoji. Kreiram ga..."
    mkdir -p "$TEMPLATE_DIR"
fi

# Download the cloud image
echo "Preuzimam cloud image..."
wget -O ${TEMPLATE_DIR}/${VM_NAME}.${IMAGE_EXT} $IMAGE_URL
if [ $? -ne 0 ]; then
    echo "Neuspješno preuzimanje cloud image-a. Izlazim."
    exit 1
fi

# Create Proxmox VM from the downloaded image
echo "Kreiram VM iz cloud image-a..."
qm create $VMID --name $VM_NAME --memory $MEMORY --net0 virtio,bridge=$BRIDGE,tag=$VLAN --ostype l26 --cores $CORES
if [ $? -ne 0 ]; then
    echo "Neuspješno kreiranje VM-a. Izlazim."
    exit 1
fi

# Import the disk
echo "Importiram disk..."
qm disk import $VMID ${TEMPLATE_DIR}/${VM_NAME}.${IMAGE_EXT} $STORAGE
if [ $? -ne 0 ]; then
    echo "Neuspješan import diska. Izlazim."
    exit 1
fi

# Configure the VM
echo "Konfigururiram VM..."
qm set $VMID --scsihw virtio-scsi-pci --scsi0 $STORAGE:vm-$VMID-disk-0
qm set $VMID --boot c --bootdisk scsi0
qm set $VMID --ide2 $STORAGE:cloudinit
qm set $VMID --serial0 socket --vga serial0
qm set $VMID --agent enabled=1
if [ $? -ne 0 ]; then
    echo "Neuspješna konfiguracija VM-a. Izlazim."
    exit 1
fi

# Resize the disk
echo "Mijenjam veličinu diska..."
qm resize $VMID scsi0 $DISK_SIZE
if [ $? -ne 0 ]; then
    echo "Neuspješna promjena veličine diska. Izlazim."
    exit 1
fi

# Cleanup
echo "Čistim privremene datoteke..."
rm -rf ${TEMPLATE_DIR}/${VM_NAME}.${IMAGE_EXT}
if [ $? -ne 0 ]; then
    echo "Neuspješno brisanje privremenih datoteka."
fi

# Completion message
echo "VM $VM_NAME s ID $VMID je uspješno kreiran s VLAN $VLAN."
