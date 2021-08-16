#!/bin/bash -eux

echo ">>>> bootstrap: installing zsh.."
pacman -Sy --noconfirm zsh

echo ">>>> bootstrap: installing OhMyZsh.."
sudo -u $USER bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo ">>>> bootstrap: installing powerlevel9k, ohmyzsh dependancy.."
git clone https://github.com/bhilburn/powerlevel9k.git /home/$USER/.oh-my-zsh/custom/themes/powerlevel9k

USER_HOME=/home/$USER

echo ">>>> bootstrap: set zsh config.."
ln -sf $USER_HOME/.cfg/linux/.zshrc $USER_HOME/.zshrc