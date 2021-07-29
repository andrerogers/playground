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

# .
echo ">>>> pacman.sh: Refresh the system packages.."
retry pacman --sync --noconfirm --refresh

echo ">>>> pacman.sh: Update the system packages.."
 retry pacman --sync --noconfirm --refresh --sysupgrade

echo ">>>> pacman.sh: Install useful tools.."
 retry pacman --sync --noconfirm --refresh vim curl wget sysstat lsof psmisc man-db mlocate net-tools haveged lm_sensors vim-runtime bash-completion

# Start the services we just added so the system will track its own performance.
echo ">>>> pacman.sh: Enabling and starting sysstat.."
systemctl enable sysstat.service && systemctl start sysstat.service

# Enable the entropy daemon.
echo ">>>> pacman.sh: Enabling and starting haveged, a random seed generator.."
systemctl enable haveged.service && systemctl start haveged.service

# Initialize the databases.
echo ">>>> pacman.sh: Initialize updatedb.."
updatedb

echo ">>>> pacman.sh: Initialize mandb.."
mandb

echo ">>>> pacman.sh: Setup vim as the default editor.."
printf "alias vi=vim\n" >> /etc/profile.d/vim.sh

# Reboot onto the new kernel (if applicable).
echo ">>>> pacman.sh: Rebooting.."
reboot