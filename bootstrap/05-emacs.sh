#!/bin/bash -eux

echo ">>>> bootstrap.sh: Install Emacs IDE.."
pacman -Sy --noconfirm emacs

echo ">>>> bootstrap.sh: link to emacs config.."
ln -sf /home/$USER/.cfg/emacs/emacs_fresh.el /home/$USER/.emacs.el

echo ">>>> bootstrap.sh: Starting Emacs in daemon mode [server].."
systemctl --user enable emacs

echo ">>>> bootstrap.sh: Install Emacs Tools (Plugin Pre-reequistes).."
pacman -Sy --noconfirm ripgrep
