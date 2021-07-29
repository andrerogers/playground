#!/bin/bash -eux

retry() {
  local COUNT=1
  local DELAY=0
  local RESULT=0
  while [[ "${COUNT}" -le 10 ]]; do
    [[ "${RESULT}" -ne 0 ]] && {
      [ "`which tput 2> /dev/null`" != "" ] && tput setaf 1
      echo -e "\\n${*} failed... retrying ${COUNT} of 10.\\n" >&2
      [ "`which tput 2> /dev/null`" != "" ] && tput sgr0
    }
    "${@}" && { RESULT=0 && break; } || RESULT="${?}"
    COUNT="$((COUNT + 1))"

    # Increase the delay with each iteration.
    DELAY="$((DELAY + 10))"
    sleep $DELAY
  done

  [[ "${COUNT}" -gt 10 ]] && {
    [ "`which tput 2> /dev/null`" != "" ] && tput setaf 1
    echo -e "\\nThe command failed 10 times.\\n" >&2
    [ "`which tput 2> /dev/null`" != "" ] && tput sgr0
  }

  return "${RESULT}"
}

echo ">>>> virtualbox.sh: Bail if we are not running atop VirtualBox.."
retry pacman --sync --noconfirm dmidecode

if [[ `dmidecode -s system-product-name` != "VirtualBox" ]]; then
    exit 0
fi

echo ">>>> virtualbox.sh: Installing VirtualBox Guest Additions.."
retry pacman -S --noconfirm linux-headers virtualbox-guest-utils nfs-utils
echo -e 'vboxguest\nvboxsf\nvboxvideo' > /etc/modules-load.d/virtualbox.conf

echo ">>>> virtualbox.sh: Add groups for VirtualBox folder sharing.."
usermod --append --groups vagrant,vboxsf vagrant

echo ">>>> virtualbox.sh: Enabling VirtualBox Guest service.."
systemctl enable vboxservice.service
systemctl start vboxservice.service

echo ">>>> virtualbox.sh: Enabling RPC Bind service.."
systemctl enable rpcbind.service