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