#!/bin/bash
#======================================================================
# Script Name: check_vm_autostart.sh
# Purpose: Check all running VMs and verify if autostart is enabled
#======================================================================

echo "Checking running VMs and their autostart status..."
echo "------------------------------------------------------"

# Get all running VMs
RUNNING_VMS=$(virsh list --state-running --name)

if [[ -z "$RUNNING_VMS" ]]; then
    echo "No VMs are currently running."
    exit 0
fi

# Loop through each running VM
for vm in $RUNNING_VMS; do
    AUTOSTART_STATUS=$(virsh dominfo "$vm" | awk '/Autostart/ {print $2}')
    echo "VM: $vm  -->  Autostart: $AUTOSTART_STATUS"
done

echo "------------------------------------------------------"
echo "Check complete."
