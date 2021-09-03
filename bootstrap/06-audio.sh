#!/bin/bash -eux

echo ">>>> bootstrap: install audio driver and controller.."
pacman -Sy --noconfirm alsa-utils 
