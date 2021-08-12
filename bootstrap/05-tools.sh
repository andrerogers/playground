#!/bin/bash -eux

echo ">>>> bootstrap.sh: Install Emacs IDE.."
pacman -Sy --noconfirm emacs

echo ">>>> bootstrap.sh: Install Emacs Tools (Plugin Pre-reequistes).."
pacman -Sy --noconfirm ripgrep

echo ">>>> bootstrap.sh: install neovim.."
pacman -Sy --noconfirm vim neovim 

# Install tools - pacman -Sy --noconfirm docker
# Install anaconda to manage python environments
# Install NVM

USER_HOME=/home/$USER

echo ">>>> bootstrap: linking to config.."
ln -sf $USER_HOME/.cfg/emacs/emacs.el $USER_HOME/.emacs.el
ln -s $USER_HOME/.cfg/emacs/.emacs.d $USER_HOME/.emacs.d