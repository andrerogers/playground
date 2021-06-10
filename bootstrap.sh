#!/bin/bash

USER=senor-dre

echo ">>>> bootstrap.sh: Setting ssh key.."
cp -r /home/vagrant/.ssh /root/
cp /home/vagrant/.ssh /home/$USER/

cat /root/.ssh/git.pub >  /root/authorized_keys
cat /home/$USER/.ssh/git.pub >>  /home/$USER/.ssh/authorized_keys

chmod -R 700 /root/.ssh
chmod -R 700 /home/$USER/.ssh

#systemctl restart sshd

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
	Modeline        "3840x2160_60.00"  108.88  3840 1920 1280 1360 1496 1712  2160 1080 1024 1025 1028 1060  -HSync +Vsync
    	Option          "PreferredMode" "3840x2160_60.00"
	Option		"Primary" "true"
EndSection
EOF

echo ">>>> bootstrap.sh: Installing OhMyZsh.."
sudo -u $USER bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo ">>>> bootstrap.sh: Installing powerlevel9k, ohmyzsh dependancy.."
git clone https://github.com/bhilburn/powerlevel9k.git /home/$USER/.oh-my-zsh/custom/themes/powerlevel9k

echo ">>>> bootstrap.sh: Installing dot files.."
#curl -Lsk https://tinyurl.com/playground-setup > config.sh
curl -Lsk https://tinyurl.com/test-setup-linux > config.sh
bash config.sh $USER
rm config.sh

echo ">>>> bootstrap.sh: Configuring .xinitrc.."
echo exec i3 > /home/$USER/.xinitrc
chown -R $USER:$USER /home/$USER/.*

echo ">>>> bootstrap.sh: Install Emacs IDE.."
pacman -Sy --noconfirm emacs
ln -sf /home/$USER/.cfg/emacs/emacs_fresh.el /home/$USER/.emacs.el

echo ">>>> bootstrap.sh: Starting Emacs in daemon mode [server].."
systemctl --user enable emacs

echo ">>>> bootstrap.sh: Install Emacs Tools (Plugin Pre-reequistes).."
pacman -Sy --noconfirm ripgrep

echo ">>>> bootstrap.sh: Install TMUX.."
pacman -Sy --noconfirm tmux
ln -sf /home/$USER/.cfg/linux/.tmux/.tmux.conf /home/$USER/.tmux.conf
ln -sf /home/$USER/.cfg/linux/.tmux/.tmux.conf.local /home/$USER/.tmux.conf.local

# install docker
# pacman -Sy --noconfirm docker

# Install anaconda to manage python environments

# Install nodejs and nvm
# pacman -Sy --noconfirm npm nodejs

echo ">>>> bootstrap.sh: Changing shell to zsh.."
chsh -s /bin/zsh $USER

echo ">>>> bootstrap.sh: Hot-load zsdh env.."
source /home/$USER/.zshrc

echo ">>>> bootstrap.sh: Rebooting.."
reboot
