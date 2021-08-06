#!/bin/bash -eux

echo ">>>> bootstrap.sh: disable root.."
passwd -l root

echo ">>>> bootstrap.sh: Rebooting.."
reboot