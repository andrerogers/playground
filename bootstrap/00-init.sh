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

# Install languages 
echo ">>>> bootstrap.sh: Install languages.."
pacman -Sy --noconfirm npm nodejs go

echo ">>>> bootstrap.sh: Install TMUX.."
pacman -Sy --noconfirm tmux
ln -sf /home/$USER/.cfg/linux/.tmux/.tmux.conf /home/$USER/.tmux.conf
ln -sf /home/$USER/.cfg/linux/.tmux/.tmux.conf.local /home/$USER/.tmux.conf.local

# install docker
# pacman -Sy --noconfirm docker

# Install anaconda to manage python environments

# Install NVM
