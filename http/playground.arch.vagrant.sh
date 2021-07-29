#!/bin/bash -eux

echo ">>>> playground.arch.vagrant.sh: Exporting storage device.."

if [ -e /dev/vda ]; then
  DISK=/dev/vda
elif [ -e /dev/sda ]; then
  DISK=/dev/sda
else
  echo "ERROR: There is no disk available for installation." >&2
  exit 1
fi
export DISK 

SWAP_PARTITION="${DISK}1"
ROOT_PARTITION="${DISK}2"

echo ">>>> playground.arch.vagrant.sh: Clearing partition table on ${DISK}.."
/usr/bin/sgdisk --zap ${DISK}

echo ">>>> playground.arch.vagrant.sh: Destroying magic strings and signatures on ${DISK}.."
/usr/bin/dd if=/dev/zero of=${DISK} bs=512 count=2048
/usr/bin/wipefs --all ${DISK}

echo ">>>> playground.arch.vagrant.sh: Creating /root partition on ${DISK}.."
/usr/bin/sgdisk --new=1:0:0 ${DISK}

echo ">>>> playground.arch.vagrant.sh: Setting ${DISK} bootable.."
/usr/bin/sgdisk ${DISK} --attributes=1:set:2

echo ">>>> playground.arch.vagrant.sh: Make swap $SWAP_PARTITION.."
/usr/bin/mkswap "${SWAP_PARTITION}"

echo ">>>> playground.arch.vagrant.sh: Creating /root filesystem (ext4) ${ROOT_PARTITION}.."
/usr/bin/mkfs.ext4 -O ^64bit -F -m 0 -q -L root ${ROOT_PARTITION}

echo ">>>> playground.arch.vagrant.sh: Mounting ${ROOT_PARTITION} to /mnt.."
/usr/bin/mount -o noatime,errors=remount-ro ${ROOT_PARTITION} /mnt 

# Ensure the leaseweb.net and kernel.org mirrors are always listed, so things work, even when the archlinux
# website goes offline.
printf "Server = https://mirror.leaseweb.net/archlinux/\$repo/os/\$arch\n" > /etc/pacman.d/mirrorlist
printf "Server = https://mirrors.kernel.org/archlinux/\$repo/os/\$arch\n" >> /etc/pacman.d/mirrorlist

curl -fsS "https://www.archlinux.org/mirrorlist/?country=all" > /tmp/mirrolist
grep '^#Server' /tmp/mirrolist | grep "https" | sort -R | head -n 5 | sed 's/^#//' >> /etc/pacman.d/mirrorlist

echo ">>>> playground.arch.vagrant.sh: Pacstrap, create a new system.."
pacstrap /mnt base base-devel linux grub bash sudo linux dhcpcd mkinitcpio gptfdisk openssh syslinux netctl git

swapon "${SWAP_PARTITION}"

echo ">>>> playground.arch.vagrant.sh: Populate fstab with all mount information.."
genfstab -U -p /mnt >> /mnt/etc/fstab

echo ">>>> playground.arch.vagrant.sh: Arch chroot.."
arch-chroot /mnt /bin/bash

echo ">>>> playground.arch.vagrant.sh: Configuring syslinux.."
/usr/bin/arch-chroot /mnt syslinux-install_update -i -a -m
/usr/bin/sed -i "s|sda3|${ROOT_PARTITION##/dev/}|" "${TARGET_DIR}/boot/syslinux/syslinux.cfg"
/usr/bin/sed -i 's/TIMEOUT 50/TIMEOUT 10/' "${TARGET_DIR}/boot/syslinux/syslinux.cfg"

[ -f /mnt/etc/fstab.pacnew ] && rm -f /mnt/etc/fstab.pacnew

swapoff "${SWAP_PARTITION}"
