#!/bin/bash -eux

USER_HOME_DIR=/home/$USER

echo ">>>> bootstrap: enabling ssh daemon.."
systemctl enable sshd

echo ">>>> bootstrap: setting ssh key.."
ROOT_SSH_DIR=/root/.ssh
USER_SSH_DIR=$USER_HOME_DIR/.ssh

pushd $ROOT_SSH_DIR
  echo ">>>> bootstrap: add jarvis.pub to authorized keys (root).."
  cat jarvis.pub >> authorized_keys

  echo ">>>> bootstrap: add github.com to known_hosts (root).."
  echo "github.com ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==" >> known_hosts

  chmod 600 jarvis

  echo ">>>> bootstrap: verify ssh agent (root).."
  eval `ssh-agent -s`

  echo ">>>> bootstrap: add git key to ssh agent (root).."
  ssh-add jarvis

  echo ">>>> bootstrap: Installing dot files.."
  # curl -Lsk https://tinyurl.com/test-setup-linux | bash -s $USER
  curl -Lsk https://tinyurl.com/02-linux-setup | bash -s $USER
popd

mv $ROOT_SSH_DIR/* $USER_SSH_DIR

echo ">>>> bootstrap: ensure ownership for ${USER} in home directory.."
chown -R $USER:$USER $USER_HOME_DIR/.*

echo ">>>> bootstrap: ensure permissions for ${USER} in home directory.."
chmod -R 777 $USER_HOME_DIR/.*

pushd $USER_SSH_DIR
  chmod 600 jarvis
popd

echo ">>>> bootstrap: linking to config.."
ln -sf $USER_HOME_DIR/.cfg/linux/.config $USER_HOME_DIR/.config
ln -sf $USER_HOME_DIR/.cfg/linux/.bashrc $USER_HOME_DIR/.bashrc
ln -sf $USER_HOME_DIR/.cfg/linux/.Xresources $USER_HOME_DIR/.Xresources
ln -sf $USER_HOME_DIR/.cfg/linux/.xinitrc $USER_HOME_DIR/.xinitrc
ln -sf $USER_HOME_DIR/.cfg/linux/.urxvt $USER_HOME_DIR/.urxvt
ln -sf $USER_HOME_DIR/.cfg/linux/.tmux/.tmux.conf $USER_HOME_DIR/.tmux.conf
ln -sf $USER_HOME_DIR/.cfg/linux/.tmux/.tmux.conf.loca1 $USER_HOME_DIR/.tmux.conf.local
ln -sf $USER_HOME_DIR/.cfg/linux/.lock.sh $USER_HOME_DIR/.lock.sh
ln -sf $USER_HOME_DIR/.cfg/linux/.grab-lockscreen.sh $USER_HOME_DIR/.grab-lockscreen.sh
ln -sf $USER_HOME_DIR/.cfg/linux/.dmrc $USER_HOME_DIR/.dmrc
ln -sf $USER_HOME_DIR/.cfg/linux/.dircolors $USER_HOME_DIR/.dircolors