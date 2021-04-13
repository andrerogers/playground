#!/bin/bash

useradd -m -s /bin/bash -U andre -u 666 --groups wheel
cp -pr /home/vagrant/.ssh /home/andre/
chown -R andre:andre /home/andre
echo "%andre ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/andre
passwd -d andre

pacman -Sy --noconfirm which 

# Install pacman-contrib package
sudo pacman -S --noconfirm pacman-contrib

# Update mirrorlist
wget archlinux.org/mirrorlist/?country=US –O /etc/pacman.d/mirrorlist 
# cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak 
# sed -i 's/^#Server/Server/' /etc/pacman.d/mirrorlist.bak 
sed -i 's/^#Server/Server/' /etc/pacman.d/mirrorlist 
# rankmirrors –n 3 /etc/pacman.d/mirrorlist.bak > /etc/pacman.d/mirrorlist 

# Update Arch database
pacman -Syy

# Update Arch
pacman -Syu --noconfirm

# Set clock
timedatectl set-ntp true
hwclock --systohc --localtime

# Remove package virtualbox-guest-utils-nox (VirtualBox Guest utilities without X support)
pacman -Rsu --noconfirm virtualbox-guest-utils-nox

# Install xorg
pacman -Sy --noconfirm xorg \
       xorg-server-xwayland xorg-server-common \
       xorg-server xorg-xinit \
       xf86-video-fbdev xf86-video-vesa \
       xorg-xrandr 

# Add user vagrant to video group
gpasswd -a vagrant video

# Install virtualbox-guest-utils (VirtualBox Guest utilities with X support)
pacman -Sy --noconfirm virtualbox-guest-iso
pacman -Sy --noconfirm virtualbox-guest-utils
pacman -Sy --noconfirm virtualbox-guest-dkms


# Install utils
pacman -Sy --noconfirm inetutils git picom scrot imagemagick \
       autoconf automake libtool w3m

# Install AUR helper
pushd /tmp
git clone https://aur.archlinux.org/yay.git
chown -R andre yay
pushd yay
sudo -u andre makepkg -si --noconfirm
popd
rm -rf yay
popd

# Install i3
pacman -Sy --noconfirm i3-wm

# Install i3lock-fancy, for lockscreen
sudo -u andre yay -S --noconfirm betterlockscreen-git 

# Install fonts 
pacman -S --noconfirm ttf-dejavu # i3 dependancy
pacman -Sy --noconfirm ttf-fira-code
fc-cache -f -v

# Install i3 pre-requisites
# Status Bar
pacman -Sy --noconfirm i3blocks 

# Terminal
pacman -Sy --noconfirm rxvt-unicode
# urxvt extensions
sudo -u andre yay -S --noconfirm urxvt-font-size-git

# Set urxvt extensions to the correct path
mkdir -p /home/vagrant/.urxvt/ext
cp -r /usr/lib/urxvt/perl/* /home/vagrant/.urxvt/ext/

# Install run launcher
pacman -Sy --noconfirm rofi

# Install file manager 
pacman -Sy --noconfirm ranger 

# Configure xorg to set resolution to 1920X1080
XORG_DIR="/etc/X11/xorg.conf.d"
if [ -d "$XORG_DIR" ]; then
  echo "${XORG_DIR} found, setting screen resolution.."
else
  echo "${XORG_DIR} not found, creating, and setting screen resolution.."
  mkdir -p $XORG_DIR
fi

cat > $XORG_DIR/10-set-screen.conf <<EOF
Section "Screen"
	Identifier	"DisplayPort-0"
	Option		"Primary" "true"
	Option		"PreferredMode" "true"
	Option		"Position" "1200 0"
EndSection
EOF

# TODO
# curl dot files config
# link config to $HOME, i.e ln -sf $HOME/.cfg/linux/.config %HOME/.config
curl -Lsk http://bit.do/initialize-linux | bash

# Install emacs 
pacman -Sy --noconfirm emacs 
ln -sf /home/andre/.cfg/emacs/custom-file.el /home/andre/.emacs.d/ 
ln -sf /home/andre/.cfg/emacs/init.el /home/andre/.emacs.el 

# Configure xinitrc for i3
# echo exec i3 > /home/vagrant/.xinitrc
chown andre:andre /home/andre/.xinitrc

# TODO: test
# Reboot to initialize changes
reboot

# TODO: test
# Start i3
# [[ -z \$DISPLAY ]] && [[ \$(tty) = /dev/tty1 ]] && exec start
