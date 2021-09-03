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
echo ">>>> bootstrap: install languages.."
pacman -Sy --noconfirm npm nodejs go

echo ">>>> bootstrap: install TMUX.."
pacman -Sy --noconfirm tmux