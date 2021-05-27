#!/bin/bash

USER=senor-dre

echo ">>>> bootstrap.sh: Setting ssh key.."
mkdir -p /home/$USER/.ssh
cp /home/vagrant/.ssh/* /home/$USER/.ssh/
chmod -R 700 /home/$USER/.ssh

# Set clock
echo ">>>> bootstrap.sh: Setting clock.."
timedatectl set-ntp true
hwclock --systohc --localtime

# Update Arch database
echo ">>>> bootstrap.sh: Updating pacman database.."
pacman -Syy

# Update Arch
echo ">>>> bootstrap.sh: Updating arch.."
pacman -Syu --noconfirm

# Install packages
echo ">>>> bootstrap.sh: Installing packages.."
echo ">>>> bootstrap.sh: Installing util packages and libraries.."
pacman -Sy --noconfirm inetutils binutils make git gcc \
                       clang autoconf automake libtool w3m

echo ">>>> bootstrap.sh: Installing Xorg.."
pacman -Sy --noconfirm xorg \
       xorg-server-xwayland xorg-server-common \
       xorg-server xorg-xinit \
       xf86-video-fbdev xf86-video-vesa \
       xorg-xrandr

echo ">>>> bootstrap.sh: Installing AUR Helper yay.."
pushd /tmp
git clone https://aur.archlinux.org/yay.git
chown -R $USER yay
pushd yay
sudo -u $USER makepkg -si --noconfirm
popd
rm -rf yay
popd

echo ">>>> bootstrap.sh: Installing zsh.."
pacman -Sy --noconfirm zsh

echo ">>>> bootstrap.sh: Installing i3.."
pacman -Sy --noconfirm i3-wm

echo ">>>> bootstrap.sh: Installing i3 dependancy, dejavu font.."
pacman -S --noconfirm ttf-dejavu # i3 dependancy

echo ">>>> bootstrap.sh: Installing Fira Code font.."
pacman -Sy --noconfirm ttf-fira-code
fc-cache -f -v

echo ">>>> bootstrap.sh: Installing i3 utils.."
pacman -Sy --noconfirm i3blocks picom scrot imagemagick \
                       rxvt-unicode rofi ranger \

echo ">>>> bootstrap.sh: Installing i3 utils via yay.."
sudo -u $USER yay -S --noconfirm betterlockscreen-git
sudo -u $USER yay -S --noconfirm urxvt-font-size-git


echo ">>>> bootstrap.sh: Setting URXVT extension path.."
mkdir -p /home/vagrant/.urxvt/ext
cp -r /usr/lib/urxvt/perl/* /home/vagrant/.urxvt/ext/

echo ">>>> bootstrap.sh: Configuring xorg to set resolution to 1920X1080.."
echo ">>>> bootstrap.sh: Creating file /etc/X11/xorg.conf.d.."
XORG_DIR="/etc/X11/xorg.conf.d"
if [ -d "$XORG_DIR" ]; then
  echo "${XORG_DIR} found, setting screen resolution.."
else
  echo "${XORG_DIR} not found, creating, and setting screen resolution.."
  mkdir -p $XORG_DIR
fi

echo ">>>> bootstrap.sh: Creating file /etc/X11/10-set-screen.conf.."
cat > $XORG_DIR/10-set-screen.conf <<EOF
Section "Screen"
	Identifier	"DisplayPort-0"
	Option		"Primary" "true"
	Option		"PreferredMode" "true"
	Option		"Position" "1200 0"
EndSection
EOF

echo ">>>> bootstrap.sh: Installing OhMyZsh.."
sudo -u $USER bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo ">>>> bootstrap.sh: Installing powerlevel9k, ohmyzsh dependancy.."
git clone https://github.com/bhilburn/powerlevel9k.git /home/$USER/.oh-my-zsh/custom/themes/powerlevel9k

echo ">>>> bootstrap.sh: Installing dot files.."
#curl -Lsk https://tinyurl.com/playground-setup > config.sh
curl -Lsk https://bitbucket.org/!api/2.0/snippets/dre-codes/yXreX6/e6411aa6cee93179a70b605c2676fbd4ef48118c/files/bootstrap.sh > config.sh
bash config.sh $USER
rm config.sh

echo ">>>> bootstrap.sh: Configuring .xinitrc.."
echo exec i3 > /home/$USER/.xinitrc
chown -R $USER:$USER /home/$USER/.*

echo ">>>> bootstrap.sh: Install Emacs IDE.."
pacman -Sy --noconfirm emacs
echo "alias e=emacs -l ~/.cfg/emacs/emacs-fresh.el" >> /home/$USER/.zshrc

# install docker
# pacman -Sy --noconfirm docker

# Install anaconda to manage python environments

# Install nodejs and nvm
# pacman -Sy --noconfirm npm nodejs

echo ">>>> bootstrap.sh: Changing shell to zsh.."
chsh -s /bin/zsh $USER

echo ">>>> bootstrap.sh: Rebooting.."
reboot
