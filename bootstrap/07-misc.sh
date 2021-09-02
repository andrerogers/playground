#!/bin/bash -eux

echo ">>>> bootstrap: install figlet.."
pacman -Sy --noconfirm figlet

echo ">>>> bootstrap: install screenfetch.."
pacman -Sy --noconfirm screenfetch 