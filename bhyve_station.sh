#!/bin/bash

echo "BHYVE S t a t i o n 0.1"
echo "======================="
echo ""
echo "============by Wamphyre"

sleep 3

echo "Installing required packages..."

sleep 2

echo ""

pkg install -y vm-bhyve grub2-bhyve

echo ""

echo "Loading Kernel Modules"

sleep 2

echo ""

kldload if_bridge if_tap nmdm vmm

echo ""

echo "Setting configuration for BHYVE-VM"

sleep 2

echo ""

sysrc vm_enable="YES"
sysrc vm_list=""
sysrc vm_delay="5"

echo ""

echo "MACHINE TYPES"

echo ""

echo "--- FreeBSD"
echo "--- GNU/Linux"
echo "--- Windows"

echo ""

echo ; read -p "What kind of machine you need?: " VM;

echo ""

echo ; read -p "Name for your machine: " NAME;

echo ""

echo ; read -p "Hard Drive Size: (example 20G): " GB;

echo ""

truncate -s "$GB"G $NAME.img

echo ""

echo ; read -p "Directory for ISO file: " DIR;

echo ""

ls $DIR | grep ".iso"

echo ""

echo ; read -p "I need the name of the ISO file: " ISO;

echo ""

echo ; read -p "Number of cores for VM: " CORES;

echo ""

echo ; read -p "RAM Memory for the VM: (In MB) " RAM;

echo ""

if [ "$VM" = "FreeBSD" ]; then

echo ""

sh /usr/share/examples/bhyve/vmrun.sh -c $CORES -m "$RAM"M -t tap0 -d $NAME.img -i -I "$DIR"/"$ISO" $NAME

echo ""

echo "Use this to launch the BHYVE Machine: sh /usr/share/examples/bhyve/vmrun.sh -c $CORES -m '$RAM'M -t tap0 -d $NAME"

echo ""

elif [ "$VM" = "GNU/Linux" ] then;

echo ""

touch device.map

echo "(hd0) ./$NAME.img
(cd0) ./$ISO" >> device.map

grub-bhyve -m device.map -r cd0 -M "$RAM"M $NAME

echo ""

echo "Use this to launch the BHYVE Machine: bhyve -A -H -P -s 0:0,hostbridge -s 1:0,lpc -s 2:0,virtio-net,tap0 \
    -s 3:0,virtio-blk,./linux.img -l com1,stdio -c $CORES -m '$RAM'M $NAME"

else ; fi






