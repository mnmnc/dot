#!/bin/sh

# ------------------------------
# PART 0: QEMU Commands
# ------------------------------

#qemu-img create -f qcow2 Void.qcow2 50G # Create 50GB VM
#qemu-system-x86_64 -m 2048 -k de -boot d -cdrom void-live-x86_64-20160420.iso void.qcow2 # Install VM
#qemu-system-x86_64 -m 2048 -k de -smp 2 -vga std -soundhw ac97 void.qcow2 # Run VM
#qemu-img create -f qcow2 -b Void.qcow2 Void_before_X.qcow2 # Create Snapshot before X
#qemu-img convert -O vdi void.qcow2 Void.vdi # Convert Qemu to VirtualBox