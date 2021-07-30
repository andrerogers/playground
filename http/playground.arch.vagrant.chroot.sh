#!/bin/bash -eux

echo ">>>> playground.arch.vagrant.sh: Adding hostname, playground.codelazy.."
echo "playground.codelazy" > /etc/hostname

echo ">>>> playground.arch.vagrant.sh: Configuring time, keymap, and locale.."
ln -sf /usr/share/zoneinfo/UTC /etc/localtime
echo 'KEYMAP=us' > /etc/vconsole.conf
sed -i -e 's/^#\(en_US.UTF-8\)/\1/' /etc/locale.gen
locale-gen
echo 'LANG=en_US.UTF-8' > /etc/locale.conf

echo ">>>> playground.arch.vagrant.sh: Creating initial ramdisk environment.."
sed -i -e 's/^#default_options=""/default_options="-S autodetect"/g' /etc/mkinitcpio.d/linux.preset
mkinitcpio -p linux

echo ">>>> playground.arch.vagrant.sh: Adding user vagrant.."
# usermod -a -G sudo vagrant 
echo -e 'vagrant\nvagrant' | passwd
useradd -m -U vagrant 
echo -e 'vagrant\nvagrant' | passwd vagrant 
cat <<-EOF > /etc/sudoers.d/vagrant
Defaults:$USER !requiretty
vagrant ALL=(ALL) NOPASSWD: ALL
EOF
chmod 440 /etc/sudoers.d/vagrant

# echo ">>>> playground.arch.vagrant.sh: Configuring ssh access for user vagrant.."
# install --directory --owner=vagrant --group=vagrant --mode=0700 /home/vagrant/.ssh
# /usr/bin/curl --output /home/vagrant/.ssh/authorized_keys --location https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub
# /usr/bin/chown vagrant:vagrant /home/vagrant/.ssh/authorized_keys
# /usr/bin/chmod 0600 /home/vagrant/.ssh/authorized_keys

sed -i -e "s/.*PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config
sed -i 's/#UseDNS yes/UseDNS no/' /etc/ssh/sshd_config

echo ">>>> playground.arch.vagrant.sh: Setting up network, eth0.."
mkdir -p /etc/systemd/network
ln -sf /dev/null /etc/systemd/network/99-default.link
ln -sf /dev/null /etc/udev/rules.d/80-net-setup-link.rules

cat <<EOF > /etc/systemd/network/eth0.network
[Match]
Name=eth0

[Network]
DHCP=ipv4
EOF

# TODO
# echo ">>>> playground.arch.vagrant.sh: Configuring DNS, editing /etc/systemd/resolved.conf.."
# sed -i -e "s/#DNS=.*/DNS=4.2.2.1 4.2.2.2 208.67.220.220/g" /etc/systemd/resolved.conf
# sed -i -e "s/#FallbackDNS=.*/FallbackDNS=4.2.2.1 4.2.2.2 208.67.220.220/g" /etc/systemd/resolved.conf
# sed -i -e "s/#Domains=.*/Domains=/g" /etc/systemd/resolved.conf
# sed -i -e "s/#DNSSEC=.*/DNSSEC=yes/g" /etc/systemd/resolved.conf
# sed -i -e "s/#Cache=.*/Cache=yes/g" /etc/systemd/resolved.conf
# sed -i -e "s/#DNSStubListener=.*/DNSStubListener=yes/g" /etc/systemd/resolved.conf

# TODO
# echo ">>>> playground.arch.vagrant.sh: Configuring DNS, creating /etc/resolv.conf.."
# cat <<-EOF > /etc/resolv.conf
# nameserver 4.2.2.1
# nameserver 4.2.2.2
# nameserver 208.67.220.220
# EOF

# echo ">>>> playground.arch.vagrant.sh: Starting resolved service.."
# systemctl enable systemd-resolved

echo ">>>> playground.arch.vagrant.sh: Starting dhcpd service.."
systemctl enable dhcpcd@eth0

echo ">>>> playground.arch.vagrant.sh: Starting netowrkd service.."
systemctl enable systemd-networkd

echo ">>>> playground.arch.vagrant.sh: Starting sshd service.."
rm --force /run/systemd/generator.early/sshd.service && systemctl enable sshd

echo ">>>> playground.arch.vagrant.sh: Ensure the network is always eth0.."
sed -i -e 's/^GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"$/GRUB_CMDLINE_LINUX_DEFAULT="\1 net.ifnames=0 biosdevname=0 elevator=noop vga=792"/g' /etc/default/grub
sed -i -e 's/^GRUB_TIMEOUT=.*$/GRUB_TIMEOUT=5/' /etc/default/grub

echo ">>>> playground.arch.vagrant.sh: install grub.."
grub-install "$DISK"
grub-mkconfig -o /boot/grub/grub.cfg

echo ">>>> playground.arch.vagrant.sh: Complete.."