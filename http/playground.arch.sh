#!/bin/bash

set -e
set -x

if [ -e /dev/vda ]; then
  device=/dev/vda
elif [ -e /dev/sda ]; then
  device=/dev/sda
else
  echo "ERROR: There is no disk available for installation" >&2
  exit 1
fi
export device

memory_size_in_kilobytes=$(free | awk '/^Mem:/ { print $2 }')
swap_size_in_kilobytes=$((memory_size_in_kilobytes * 2))
sfdisk "$device" <<EOF
label: dos
size=${swap_size_in_kilobytes}KiB, type=82
                                   type=83, bootable
EOF
mkswap "${device}1"
mkfs.ext4 "${device}2"
mount "${device}2" /mnt

printf "Server = https://mirror.leaseweb.net/archlinux/\$repo/os/\$arch\n" > /etc/pacman.d/mirrorlist
printf "Server = https://mirrors.kernel.org/archlinux/\$repo/os/\$arch\n" >> /etc/pacman.d/mirrorlist

curl -fsS "https://www.archlinux.org/mirrorlist/?country=all" > /tmp/mirrolist
grep '^#Server' /tmp/mirrolist | grep "https" | sort -R | head -n 5 | sed 's/^#//' >> /etc/pacman.d/mirrorlist

# pacstrap /mnt base grub openssh sudo
pacstrap /mnt base base-devel linux grub bash sudo linux dhcpcd mkinitcpio gptfdisk openssh syslinux netctl git

swapon "${device}1"
genfstab -p /mnt >> /mnt/etc/fstab
swapoff "${device}1"

# chroot

TARGET_DIR='/mnt'
CONFIG_SCRIPT='/usr/local/bin/arch-config.sh'

echo ">>>> install-base.sh: Generating the system configuration script.."
install --mode=0755 /dev/null "${TARGET_DIR}${CONFIG_SCRIPT}"

CONFIG_SCRIPT_SHORT=`basename "$CONFIG_SCRIPT"`
cat <<-EOF > "${TARGET_DIR}${CONFIG_SCRIPT}"
ln -sf /usr/share/zoneinfo/UTC /etc/localtime

echo 'playground' > /etc/hostname

sed -i -e 's/^#\(en_US.UTF-8\)/\1/' /etc/locale.gen
locale-gen
echo 'LANG=en_US.UTF-8' > /etc/locale.conf

mkinitcpio -p linux

echo root:packer | chpasswd

useradd -m -p \$(openssl passwd -crypt "${CONFIG_USER}") ${CONFIG_USER}
usermod -a -G wheel ${CONFIG_USER}
sed '/^# %wheel ALL=(ALL) ALL/ s/^# //' -i /etc/sudoers
install --directory --owner=${CONFIG_USER} --group=${CONFIG_USER} --mode=0700 /home/${CONFIG_USER}/.ssh

useradd -m -p \$(openssl passwd "packer") vagrant 
usermod -a -G wheel vagrant 
install --directory --owner=vagrant --group=vagrant --mode=0700 /home/vagrant/.ssh

sed -i -e "s/.*PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config
echo 'UseDNS no' >> /etc/ssh/sshd_config

mkdir -p /etc/systemd/network
ln -sf /dev/null /etc/udev/rules.d/80-net-setup-link.rules
ln -sf /dev/null /etc/systemd/network/99-default.link

cat <<NET > /etc/systemd/network/eth0.network
[Match]
Name=eth0

[Network]
DHCP=ipv4
NET

systemctl enable dhcpcd@eth0.service
systemctl enable systemd-networkd
systemctl enable sshd.service

grub-install "$device"
sed -i -e 's/^GRUB_TIMEOUT=.*$/GRUB_TIMEOUT=1/' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg
EOF

echo ">>>> install-base.sh: Entering chroot and configuring system.."
arch-chroot ${TARGET_DIR} ${CONFIG_SCRIPT}
rm "${TARGET_DIR}${CONFIG_SCRIPT}"

echo ">>>> install-base.sh: Completing installation.."
sleep 3
umount ${TARGET_DIR}

# Turning network interfaces down to make sure SSH session was dropped on host.
# More info at: https://www.packer.io/docs/provisioners/shell.html#handling-reboots
# echo ">>>> install-base.sh: Turning down network interfaces and rebooting.."
for i in $(ip -o link show | awk -F': ' '{print $2}'); do if [ $i != "lo" ]; then ip link set $i down; fi; done

reboot