#!/bin/bash -eux

# One clean param removes packages that are no longer
# installed. The second clean param removes the entire cache.
echo ">>>> cleanup.sh: Clean the package cache.."
pacman --sync --noconfirm --clean --clean

echo ">>>> cleanup.sh: Clear the random seed.."
rm -f /var/lib/systemd/random-seed

rm -rf /root/VBoxVersion.txt
rm -rf /root/VBoxGuestAdditions.iso

# echo ">>>> cleanup.sh: Cleaning pacman cache.."
# /usr/bin/pacman -Scc --noconfirm

# if [[ $WRITE_ZEROS == "true" ]]; then
#   echo ">>>> cleanup.sh: Writing zeros to improve virtual disk compaction.."

#   zerofile=$(/usr/bin/mktemp /zerofile.XXXXX)
#   /usr/bin/dd if=/dev/zero of="$zerofile" bs=1M
#   /usr/bin/rm -f "$zerofile"
#   /usr/bin/sync
# fi

echo ">>>> cleanup.sh: Complete.."
