#!/bin/bash -eux

USER_HOME_DIR=/home/$USER

echo ">>>> bootstrap.sh: Setting ssh key.."
ROOT_SSH_DIR=/root/.ssh
USER_SSH_DIR=$USER_HOME_DIR/.ssh

pushd $ROOT_SSH_DIR
  echo ">>>> bootstrap.sh: add jarvis.pub to authorized keys (root).."
  cat jarvis.pub >> authorized_keys

  echo ">>>> bootstrap.sh: add github.com to known_hosts (root).."
  echo "github.com ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==" >> known_hosts

  chmod 600 jarvis

  echo ">>>> bootstrap.sh: verify ssh agent (root).."
  eval `ssh-agent -s`

  echo ">>>> bootstrap.sh: add git key to ssh agent (root).."
  ssh-add jarvis

  echo ">>>> bootstrap.sh: Installing dot files.."
  # curl -Lsk https://tinyurl.com/test-setup-linux | bash -s $USER
  curl -Lsk https://tinyurl.com/01-setup-linux | bash -s $USER
popd

mv $ROOT_SSH_DIR/* $USER_SSH_DIR

echo ">>>> bootstrap.sh: ensure ownership for ${USER} in home directory.."
chown -R $USER:$USER $USER_HOME_DIR/.*

echo ">>>> bootstrap.sh: ensure permissions for ${USER} in home directory.."
chmod -R 777 $USER_HOME_DIR/.*

pushd $USER_SSH_DIR
  echo ">>>> bootstrap.sh: set appropriate permissions for git key ($USER).."
  chmod 600 jarvis

  echo ">>>> bootstrap.sh: verify ssh agent ($USER).."
  eval `ssh-agent -s`

  echo ">>>> bootstrap.sh: add git key to ssh agent ($USER).."
  ssh-add jarvis
popd

