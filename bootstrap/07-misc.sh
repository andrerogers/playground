#!/bin/bash -eux

echo ">>>> bootstrap: install figlet.."
pacman -Sy --noconfirm figlet

echo ">>>> bootstrap: install screenfetch.."
pacman -Sy --noconfirm screenfetch 

echo ">>>> bootstrap: install feh for setting wallpaper.."
pacman -Sy --noconfirm feh 

echo ">>>> bootstrap: install vivd for setting LS_COLORS theme.."
pacman -Sy --noconfirm vivid 

# TODO
# put an if else clause to check if headless
echo ">>>> bootstrap: install brave browser.."
sudo -u $USER yay -S --noconfirm brave-bin 