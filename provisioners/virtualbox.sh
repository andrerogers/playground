
#!/bin/bash

set -e
set -x

if [ "$PACKER_BUILDER_TYPE" != "virtualbox-iso" ]; then
  exit 0
fi

echo ">>>> virtualbox.sh: Installing VirtualBox Guest Additions.."
pacman -S --noconfirm linux-headers virtualbox-guest-utils nfs-utils
echo -e 'vboxguest\nvboxsf\nvboxvideo' > /etc/modules-load.d/virtualbox.conf

echo ">>>> virtualbox.sh: Add groups for VirtualBox folder sharing.."
usermod --append --groups vboxsf $CONFIG_USER 

echo ">>>> virtualbox.sh: Enabling VirtualBox Guest service.."
systemctl enable vboxservice.service
systemctl start vboxservice.service

echo ">>>> virtualbox.sh: Enabling RPC Bind service.."
systemctl enable rpcbind.service