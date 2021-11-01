#!/bin/bash -eux

# Set clock
echo ">>>> bootstrap: setting clock.."
timedatectl set-ntp true
hwclock --systohc --localtime

# Update Arch database
echo ">>>> bootstrap: updating pacman database.."
pacman -Syy

# Update Arch
echo ">>>> bootstrap: updating arch.."
pacman -Syu --noconfirm

# Install packages
echo ">>>> bootstrap: installing packages.."
echo ">>>> bootstrap: installing util packages and libraries.."
pacman -Sy --noconfirm inetutils binutils make git gcc \
                       clang autoconf automake libtool \
                       usbutils w3m

# Install languages 
echo ">>>> bootstrap: install npm and node for javascript.."
pacman -Sy --noconfirm npm nodejs

echo ">>>> bootstrap: install golang.."
pacman -Sy --noconfirm go

echo ">>>> bootstrap: install javascript compilers via npm.."
npm install -g typescript solc ethlint 

echo ">>>> bootstrap: install javascript linters via npm.."
npm install -g eslint prettier 

echo ">>>> bootstrap: install TMUX.."
pacman -Sy --noconfirm tmux