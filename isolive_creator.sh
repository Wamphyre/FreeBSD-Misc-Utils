#!/bin/sh

# Variables
ISO_NAME="FreeBSD-LiveCD.iso"
WORK_DIR="/tmp/livecd-workdir"
MOUNT_DIR="/tmp/livecd-mountdir"
LIVECD_ROOT="/usr/local/livecd"

# Crea el directorio de trabajo
mkdir -p ${WORK_DIR}

# Monta la imagen de FreeBSD
mount -t unionfs /dev/ufs/root ${MOUNT_DIR}

# Crea una copia del sistema de archivos
cd ${MOUNT_DIR}
tar cf - . | tar xf - -C ${WORK_DIR}

# Desmonta la imagen de FreeBSD
umount ${MOUNT_DIR}

# Instala los paquetes necesarios para el LiveCD
pkg install -y sysutils/grub2-pcbsd

# Copia los archivos de configuración para el LiveCD
mkdir -p ${LIVECD_ROOT}
cp /usr/local/share/grub/grub.cfg ${LIVECD_ROOT}

# Genera la imagen ISO del LiveCD
mkisofs -R -o ${ISO_NAME} -b boot/grub/i386-pc/eltorito.img -no-emul-boot \
        -boot-load-size 4 -boot-info-table ${WORK_DIR}

# Limpia los directorios temporales
rm -rf ${WORK_DIR} ${MOUNT_DIR}
