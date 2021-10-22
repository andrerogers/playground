#!/bin/bash -eux

# TODO
# put an if else clause to check if headless

echo ">>>> bootstrap: installing Xorg.."
pacman -Sy --noconfirm xorg \
       xorg-server-xwayland xorg-server-common \
       xorg-server xorg-xinit \
       xf86-video-fbdev xf86-video-vesa \
       xorg-xrandr

echo ">>>> bootstrap: installing i3.."
pacman -Sy --noconfirm i3-wm

echo ">>>> bootstrap: installing i3 dependancy, dejavu font.."
pacman -S --noconfirm ttf-dejavu ttf-font-awesome # i3 dependancy

echo ">>>> bootstrap: installing Fira Code font.."
pacman -Sy --noconfirm ttf-fira-code
fc-cache -f -v

echo ">>>> bootstrap: installing i3 utils.."
pacman -Sy --noconfirm i3blocks picom scrot imagemagick \
                       rxvt-unicode rofi ranger \

echo ">>>> bootstrap: installing i3 utils via yay.."
sudo -u $USER yay -S --noconfirm betterlockscreen-git
sudo -u $USER yay -S --noconfirm urxvt-font-size-git

echo ">>>> bootstrap: creating file /etc/X11/xorg.conf.d.."
XORG_DIR="/etc/X11/xorg.conf.d"
if [ -d "$XORG_DIR" ]; then
  echo "${XORG_DIR} found, setting screen resolution.."
else
  echo "${XORG_DIR} not found, creating, and setting screen resolution.."
  mkdir -p $XORG_DIR
fi

echo ">>>> bootstrap: creating file /etc/X11/10-set-screen.conf.."
cat > $XORG_DIR/10-set-screen.conf <<EOF
Section "Screen"
	Identifier	"DisplayPort-0"
	# Modeline        "3840x2160_60.00"  108.88  3840 1920 1280 1360 1496 1712  2160 1080 1024 1025 1028 1060  -HSync +Vsync
  # Option          "PreferredMode" "3840x2160_60.00"
	Option		"Primary" "true"
EndSection
EOF

USER_HOME=/home/$USER

echo ">>>> bootstrap: setting urxvt extension path.."
mkdir -p $USER_HOME/.urxvt/ext
cp -r /usr/lib/urxvt/perl/* $USER_HOME/.urxvt/ext/

# echo ">>>> bootstrap: installing lightdm.."
# pacman -Sy --noconfirm lightdm lightdm-gtk-greeter accountsservice 

# echo ">>>> bootstrap: set default lightdm greeter to lightdm-webkit2-greeter.."
# sudo -u $USER yay -S --noconfirm lightdm-webkit2-theme-glorious
# sudo sed -i 's/^\(#?greeter\)-session\s*=\s*\(.*\)/greeter-session = lightdm-webkit2-greeter #\1/ #\2g' /etc/lightdm/lightdm.conf

# echo ">>>> bootstrap: set default lightdm-webkit2-greeter theme to glorious.."
# sudo sed -i 's/^webkit_theme\s*=\s*\(.*\)/webkit_theme = glorious #\1/g' /etc/lightdm/lightdm-webkit2-greeter.conf
# sudo sed -i 's/^debug_mode\s*=\s*\(.*\)/debug_mode = true #\1/g' /etc/lightdm/lightdm-webkit2-greeter.conf

# echo ">>>> bootstrap: enable lightdm.."
# systemctl enable lightdm.service
# systemctl start lightdm.service