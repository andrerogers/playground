#!/bin/bash -eux

echo ">>>> bootstrap: installing AUR Helper yay.."

pushd /tmp
git clone https://aur.archlinux.org/yay.git
chown -R $USER yay
pushd yay
# sudo -u $USER makepkg -si --noconfirm
echo packer | sudo -S -u $USER makepkg -si --noconfirm
popd
rm -rf yay
popd