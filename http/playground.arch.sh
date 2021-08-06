#!/bin/bash

set -e
set -x

TARGET_DIR='/mnt'
CONFIG_SCRIPT='/usr/local/bin/arch-config.sh'

echo ">>>> playground.arch.sh: detect block device type.."

if [ -e /dev/vda ]; then
  DEVICE=/dev/vda
elif [ -e /dev/sda ]; then
  DEVICE=/dev/sda
else
  echo "ERROR: There is no disk available for installation" >&2
  exit 1
fi
export DEVICE

echo ">>>> playground.arch.sh: block device type = ${DEVICE}.."

echo ">>>> playground.arch.sh: sfdisk => partitioning block device.."
memory_size_in_kilobytes=$(free | awk '/^Mem:/ { print $2 }')
swap_size_in_kilobytes=$((memory_size_in_kilobytes * 2))
sfdisk "$DEVICE" <<EOF
label: dos
size=${swap_size_in_kilobytes}KiB, type=82
                                   type=83, bootable
EOF

echo ">>>> playground.arch.sh: make swap on ${DEVICE}1.."
mkswap "${DEVICE}1"

echo ">>>> playground.arch.sh: format to ext4 on ${DEVICE}2.."
mkfs.ext4 "${DEVICE}2"

echo ">>>> playground.arch.sh: mount ${DEVICE}2 to ${TARGET_DIR}.."
mount "${DEVICE}2" ${TARGET_DIR}

echo ">>>> playground.arch.sh: set mirrorlist.."

printf "Server = https://mirror.leaseweb.net/archlinux/\$repo/os/\$arch\n" > /etc/pacman.d/mirrorlist
printf "Server = https://mirrors.kernel.org/archlinux/\$repo/os/\$arch\n" >> /etc/pacman.d/mirrorlist

curl -fsS "https://www.archlinux.org/mirrorlist/?country=all" > /tmp/mirrolist
grep '^#Server' /tmp/mirrolist | grep "https" | sort -R | head -n 5 | sed 's/^#//' >> /etc/pacman.d/mirrorlist

echo ">>>> playground.arch.sh: create a new system installation at ${TARGET_DIR}.."
pacstrap ${TARGET_DIR} base base-devel linux grub bash sudo linux dhcpcd mkinitcpio gptfdisk openssh syslinux netctl git

echo ">>>> playground.arch.sh: enable swapping on ${DEVICE}1.."
swapon "${DEVICE}1"

echo ">>>> playground.arch.sh: fill in fstab by autodetecting the current mounts.."
genfstab -p ${TARGET_DIR} >> ${TARGET_DIR}/etc/fstab

echo ">>>> playground.arch.sh: disable swapping on ${DEVICE}1.."
swapoff "${DEVICE}1"

echo ">>>> playground.arch.sh: about to enter chroot.."

echo ">>>> playground.arch.sh: generating the system configuration script.."
install --mode=0755 /dev/null "${TARGET_DIR}${CONFIG_SCRIPT}"

CONFIG_SCRIPT_SHORT=`basename "$CONFIG_SCRIPT"`
cat <<-EOF > "${TARGET_DIR}${CONFIG_SCRIPT}"
ln -sf /usr/share/zoneinfo/UTC /etc/localtime

echo ">>>> ${CONFIG_SCRIPT_SHORT}.arch.sh: setting the hostname.."
echo '${HOSTNAME}' > /etc/hostname

echo ">>>> ${CONFIG_SCRIPT_SHORT}.arch.sh: generating and setting lang conf.."
sed -i -e 's/^#\(en_US.UTF-8\)/\1/' /etc/locale.gen
locale-gen
echo 'LANG=en_US.UTF-8' > /etc/locale.conf

echo ">>>> ${CONFIG_SCRIPT_SHORT}.arch.sh: mkinitcpio => create inital RAMDISK.."
mkinitcpio -p linux

echo ">>>> ${CONFIG_SCRIPT_SHORT}.arch.sh: set root password to enable ssh.."
echo root:packer | chpasswd

echo ">>>> ${CONFIG_SCRIPT_SHORT}.arch.sh: add ${CONFIG_USER}.."
useradd -m -p \$(openssl passwd -crypt "${CONFIG_USER}") ${CONFIG_USER}

cat <<-SUDO > /etc/sudoers.d/${CONFIG_USER}
Defaults:${CONFIG_USER} !requiretty
${CONFIG_USER} ALL=(ALL) NOPASSWD: ALL
SUDO

chmod 440 /etc/sudoers.d/${CONFIG_USER}

echo ">>>> ${CONFIG_SCRIPT_SHORT}.arch.sh: adding ${CONFIG_USER} to groups sudo, wheel and ${CONFIG_USER}.."
usermod -a -G wheel ${CONFIG_USER}
usermod -a -G ${CONFIG_USER} ${CONFIG_USER} 

sed '/^# %wheel ALL=(ALL) ALL/ s/^# //' -i /etc/sudoers

install --directory --owner=${CONFIG_USER} --group=${CONFIG_USER} --mode=0700 /home/${CONFIG_USER}/.ssh

echo ">>>> ${CONFIG_SCRIPT_SHORT}.arch.sh: set ssh conf settings at /etc/ssh/sshd_config.."
sed -i -e "s/.*PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config
sed -i 's/#UseDNS yes/UseDNS no/' /etc/ssh/sshd_config

echo ">>>> ${CONFIG_SCRIPT_SHORT}.arch.sh: setup network .."
mkdir -p /etc/systemd/network
ln -sf /dev/null /etc/udev/rules.d/80-net-setup-link.rules
ln -sf /dev/null /etc/systemd/network/99-default.link

cat <<NET > /etc/systemd/network/eth0.network
[Match]
Name=eth0

[Network]
DHCP=ipv4
NET

echo ">>>> ${CONFIG_SCRIPT_SHORT}.arch.sh: enable dhcpcd@eth0.service .."
systemctl enable dhcpcd@eth0.service

echo ">>>> ${CONFIG_SCRIPT_SHORT}.arch.sh: enable systemd-networkd.service .."
systemctl enable systemd-networkd

echo ">>>> ${CONFIG_SCRIPT_SHORT}.arch.sh: enable sshd.service .."
systemctl enable sshd.service

echo ">>>> ${CONFIG_SCRIPT_SHORT}.arch.sh: install grub on ${DEVICE} .."
grub-install "$DEVICE"
sed -i -e 's/^GRUB_TIMEOUT=.*$/GRUB_TIMEOUT=1/' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg
EOF

echo ">>>> playground.arch.sh: entering chroot and configuring system.."
arch-chroot ${TARGET_DIR} ${CONFIG_SCRIPT}
rm "${TARGET_DIR}${CONFIG_SCRIPT}"

echo ">>>> playground.arch.sh: completing installation; unmounting ${TARGET_DIR}.."
sleep 3
umount ${TARGET_DIR}

# Turning network interfaces down to make sure SSH session was dropped on host.
# More info at: https://www.packer.io/docs/provisioners/shell.html#handling-reboots
echo ">>>> playground.arch.sh: Turning down network interfaces and rebooting.."
echo `ip -o link show | awk -F': ' '{print $2}'`
for i in $(ip -o link show | awk -F': ' '{print $2}'); do if [ $i != "lo" ]; then ip link set $i down; fi; done

reboot