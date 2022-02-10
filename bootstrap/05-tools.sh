#!/bin/bash -eux

echo ">>>> bootstrap: install flycheck.."
sudo -u $USER yay -S --noconfirm flycheck

echo ">>>> bootstrap: install emacs.."
pacman -Sy --noconfirm emacs

echo ">>>> bootstrap: install emacs tools (plugin pre-reequistes).."
pacman -Sy --noconfirm ripgrep

echo ">>>> bootstrap: install neovim.."
pacman -Sy --noconfirm vim neovim 

# Install tools - pacman -Sy --noconfirm docker
# Install anaconda to manage python environments
# Install NVM

USER_HOME=/home/$USER

echo ">>>> bootstrap: linking to config.."
ln -sf $USER_HOME/.cfg/emacs/emacs.el $USER_HOME/.emacs.el
ln -s $USER_HOME/.cfg/emacs/.emacs.d $USER_HOME/.emacs.d
ln -sf $USER_HOME/.cfg/emacs/emacsctl.sh $USER_HOME/.emacsctl.sh

echo ">>>> bootstrap: add desktop entries for emacs server and client.."
cat <<-EMACSSERVER > /usr/share/applications/emacsserver.desktop
[Desktop Entry]
Name=Emacs Server
GenericName=Text Editor
Comment=Edit text
MimeType=text/english;text/plain;text/x-makefile;text/x-c++hdr;text/x-c++src;text/x-chdr;text/x-csrc;text/x-java;text/x-moc;text/x-pascal;text/x-tcl;text/x-tex;application/x-shellscript;text/x-c;text/x-c++;
Exec=emacs --daemon=workspace
Icon=emacs
Type=Application
Terminal=true
Categories=Development;TextEditor;
StartupWMClass=Emacs
Keywords=Text;Editor;
EMACSSERVER

cat <<-EMACSCLIENT > /usr/share/applications/emacsclient.desktop
[Desktop Entry]
Name=Emacs Client
GenericName=Text Editor
Comment=Edit text
MimeType=text/english;text/plain;text/x-makefile;text/x-c++hdr;text/x-c++src;text/x-chdr;text/x-csrc;text/x-java;text/x-moc;text/x-pascal;text/x-tcl;text/x-tex;application/x-shellscript;text/x-c;text/x-c++;
Exec=emacsclient -c -s workspace
Icon=emacs
Type=Application
Terminal=false
Categories=Development;TextEditor;
StartupWMClass=Emacs
Keywords=Text;Editor;
EMACSCLIENT
