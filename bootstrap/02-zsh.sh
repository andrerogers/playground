#!/bin/bash -eux

echo ">>>> bootstrap.sh: Installing zsh.."
pacman -Sy --noconfirm zsh

echo ">>>> bootstrap.sh: Installing OhMyZsh.."
sudo -u $USER bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo ">>>> bootstrap.sh: Installing powerlevel9k, ohmyzsh dependancy.."
git clone https://github.com/bhilburn/powerlevel9k.git /home/$USER/.oh-my-zsh/custom/themes/powerlevel9k

echo ">>>> bootstrap.sh: Changing shell to zsh.."
chsh -s /bin/zsh $USER