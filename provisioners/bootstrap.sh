#!/bin/bash -eux

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

# Install languages 
echo ">>>> bootstrap.sh: Install languages.."
pacman -Sy --noconfirm npm nodejs go

echo ">>>> bootstrap.sh: Installing AUR Helper yay.."
pushd /tmp
git clone https://aur.archlinux.org/yay.git
chown -R $USER yay
pushd yay
# sudo -u $USER makepkg -si --noconfirm
echo packer | sudo -S -u $USER makepkg -si --noconfirm
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
mkdir -p /home/$USER/.urxvt/ext
cp -r /usr/lib/urxvt/perl/* /home/$USER/.urxvt/ext/

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
	# Modeline        "3840x2160_60.00"  108.88  3840 1920 1280 1360 1496 1712  2160 1080 1024 1025 1028 1060  -HSync +Vsync
  # Option          "PreferredMode" "3840x2160_60.00"
	Option		"Primary" "true"
EndSection
EOF

USER_HOME_DIR=/home/$USER

echo ">>>> bootstrap.sh: Setting ssh key.."
ROOT_SSH_DIR=/root/.ssh
USER_SSH_DIR=$USER_HOME_DIR/.ssh
# [ -d "$USER_SSH_DIR" ] && mv $ROOT_SSH_DIR/* $USER_SSH_DIR/ || mv $ROOT_SSH_DIR $USER_SSH_DIR 
mv $ROOT_SSH_DIR/* $USER_SSH_DIR

cat $USER_SSH_DIR/jarvis.pub >> $USER_SSH_DIR/authorized_keys

echo ">>>> bootstrap.sh: ensure ownership for ${USER} in home directory.."
chown -R $USER:$USER $USER_HOME_DIR/.*

echo ">>>> bootstrap.sh: ensure permissions for ${USER} in home directory.."
chmod -R 777 $USER_HOME_DIR/.*

echo ">>>> bootstrap.sh: add github.com to known_hosts.."
echo "github.com ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==" >> $USER_SSH_DIR/known_hosts

echo ">>>> bootstrap.sh: set appropriate permissions for git key.."
chmod 600 $USER_SSH_DIR/jarvis

echo ">>>> bootstrap.sh: verify ssh agent.."
eval `ssh-agent -s`

echo ">>>> bootstrap.sh: add git key to ssh agent.."
ssh-add $USER_SSH_DIR/jarvis

# echo ">>>> bootstrap.sh: ratify ssh connection with git.."
# ssh -oStrictHostKeyChecking=no -T git@github.com

echo ">>>> bootstrap.sh: Installing OhMyZsh.."
sudo -u $USER bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo ">>>> bootstrap.sh: Installing powerlevel9k, ohmyzsh dependancy.."
git clone https://github.com/bhilburn/powerlevel9k.git /home/$USER/.oh-my-zsh/custom/themes/powerlevel9k

echo ">>>> bootstrap.sh: Installing dot files.."
# sudo -u $USER curl -Lsk https://gist.githubusercontent.com/andrerogers/c2a4100f816ca837a0c819f13e719ca8/raw/5329764c2297c32cb316808265b99c81f12b0572/linux-setup.sh | bash -s $USER
sudo -u $USER bash -c "curl -Lsk https://tinyurl.com/test-setup-linux | bash -s $USER" 
# curl -Lsk https://tinyurl.com/playground-setup > config.sh
# curl -Lsk https://tinyurl.com/test-setup-linux > config.sh
# bash config.sh $USER
# rm config.sh

echo ">>>> bootstrap.sh: Configuring .xinitrc.."
XINITRC_FILE=/home/$USER/.xinitrc
echo exec i3 > $XINITRC_FILE 

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

# Install NVM

echo ">>>> bootstrap.sh: Changing shell to zsh.."
chsh -s /bin/zsh $USER

# echo ">>>> bootstrap.sh: Hot-load zsh env.."
# source /home/$USER/.zshrc


echo ">>>> bootstrap.sh: disable root.."
passwd -l root

echo ">>>> bootstrap.sh: Rebooting.."
reboot
