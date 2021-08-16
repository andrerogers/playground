#!/bin/bash -eux

USER_HOME=/home/$USER

echo ">>>> fin.sh: setting ownership for /home/$USER.."
chown -R $USER:$USER $USER_HOME/.* 

echo ">>>> fin.sh: setup runit script.."
chmod +x $USER_HOME/runit.sh

echo ">>>> fin.sh: switch shell to use zsh.."
chsh -s /bin/zsh $USER

echo ">>>> fin.sh: disable root.."
passwd -l root

echo ">>>> fin.sh: Rebooting.."
reboot