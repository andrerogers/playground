#!/bin/bash -eux

figlet -tkc -w 100 -f ivrit "playground"; figlet -tk -f script "welcome to playground"; figlet -tkc -w 100 -f standard $USER; screenfetch

echo ">>>> runit.sh: verify ssh agent (root).."
eval `ssh-agent -s`

echo ">>>> runit.sh: add git key to ssh agent (root).."
ssh-add $HOME/.ssh/jarvis

echo ">>>> runit.sh: testing git access.."
ssh -T git@github.com

echo ">>>> runit.sh: setting git config.."
git config --global user.email "andrejrogers@gmail.com"
git config --global user.name "Andre Rogers"

function config {
	/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME $@
}

config remote add origin git@github.com:andrerogers/dotfiles.git 
config branch --set-upstream-to=origin/master master
config pull origin master
config push --set-upstream origin master

echo ">>>> runit.sh: starting emacs in daemon mode [server].."
systemctl --user enable --now emacs

echo ">>>> runit.sh: remove runit.."
mv $HOME/runit.sh /tmp

echo ">>>> runit.sh: reboot1.."
sudo reboot