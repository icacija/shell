#!/bin/bash

# Automatizovana skripta za preuzimanje i deinstalaciju CSF, CSE i CMQ
# Kreirana na osnovu korisničkih komandi

set -e  # Prekini izvršavanje ako bilo koja komanda vrati grešku

# Funkcija za ispis poruka
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Funkcija za čišćenje fajlova
cleanup() {
    log_message "Čišćenje privremenih fajlova..."
    rm -f csf.tgz cse.tgz cmq.tgz
}

# Postavka trap-a za čišćenje na izlaz
trap cleanup EXIT

log_message "Početak automatizovane skripte..."

# 1. Download CSE and CSF archives
log_message "Downloading CSE archive..."
wget -q https://github.com/waytotheweb/scripts/raw/refs/heads/main/cse.tgz

log_message "Downloading CSF archive..."
wget -q https://github.com/waytotheweb/scripts/raw/refs/heads/main/csf.tgz

# 2. Extract and uninstall CSE
log_message "Extracting CSE archive..."
tar -xzf cse.tgz

if [ -d "cse" ]; then
    log_message "Entering cse directory and starting uninstallation..."
    cd cse
    
    if [ -f "uninstall.sh" ]; then
        bash uninstall.sh
    else
        log_message "WARNING: uninstall.sh not found in cse directory"
    fi
    
    cd ..
    log_message "CSE uninstallation completed"
else
    log_message "ERROR: cse directory was not created"
fi

# 3. Extract and uninstall CSF
log_message "Extracting CSF archive..."
tar -xzf csf.tgz

if [ -d "csf" ]; then
    log_message "Entering csf directory and starting uninstallation..."
    cd csf
    
    if [ -f "uninstall.sh" ]; then
        bash uninstall.sh
    else
        log_message "WARNING: uninstall.sh not found in csf directory"
    fi
    
    # 4. Download CMQ archive from csf directory
    log_message "Downloading CMQ archive..."
    wget -q https://github.com/waytotheweb/scripts/raw/refs/heads/main/cmq.tgz
    
    # 5. Extract CMQ archive
    log_message "Extracting CMQ archive..."
    tar -xzf cmq.tgz
    
    if [ -d "cmq" ]; then
        log_message "Entering cmq directory..."
        cd cmq
        
        log_message "CMQ directory contents:"
        ls -la
        
        if [ -f "uninstall.sh" ]; then
            log_message "Starting CMQ uninstallation..."
            bash uninstall.sh
        else
            log_message "WARNING: uninstall.sh not found in cmq directory"
        fi
        
        cd ..
        log_message "CMQ uninstallation completed"
    else
        log_message "ERROR: cmq directory was not created"
    fi
    
    cd ..
    log_message "CSF uninstallation completed"
else
    log_message "ERROR: csf directory was not created"
fi

log_message "Automated script completed successfully!"

# Optional: remove extracted directories
read -p "Do you want to remove extracted directories (cse, csf)? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    log_message "Removing directories..."
    rm -rf cse csf
    log_message "Directories removed"
fi
