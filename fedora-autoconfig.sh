#!/bin/bash

#Introduction and variables
echo "Welcome to my Fedora Linux autoconfig! Before we begin, I need to ask you some questions."

echo "Are you using a Logitech device? (y/n)"
read LOGITECH

echo "Do you plan on gaming with this device? (y/n)"
read GAMING

echo "Are you ok with enabling non-FOSS and potentially unsafe repositories for extra software? (This includes expanded Flatpak repos) (y/n)"
read NONFREE

echo "Do you want to use NVidia's proprietary drivers? (y/n)"
read DRIVERS

echo "Does your device have battery problems? (y/n)"
read BATTERY

echo "Would you like to use the fastest DNF mirror available to you? WARNING: This will edit /etc/dnf/dnf.conf and will slow down DNF the first time you use it with the faster mirrors. (y/n)"
read FASTESTMIRROR

#Configuration
echo "Thank you for using my autoconfig! Configuration starting now..."

#Basics
echo "Dowloading essential GNOME software..."
yes | sudo dnf install gnome-tweaks

#Mirror
if [[ $FASTESTMIRROR == "y" || $FASTESTMIRROR == "Y" ]]; then
	echo "Editing /etc/dnf/dnf.conf..."
	sudo echo "" >> /etc/dnf/dnf.conf
	sudo echo "fastestmirror=1" >> /etc/dnf/dnf.conf
else
	echo ""
fi

#Repos
if [[ $NONFREE == "y" || $NONFREE == "Y" ]]; then
	echo "Adding RPM Fusion repos/addons..."
	yes | sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
	yes | sudo dnf groupupdate core
	yes | sudo dnf groupupdate multimedia --setop="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin
	yes | sudo dnf groupupdate sound-and-video
	echo "Adding extra Flatpak repos..."
	yes | flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
else
	echo ""
fi

#Logitech 
if [[ $LOGITECH == "y" || $LOGITECH == "Y" ]]; then
	echo "Installing Solaar for Logitech device control."
	yes | sudo dnf install solaar
else
	echo ""
fi

#Gaming
if [[ $GAMING == "y" || $GAMING == "Y" ]]; then
	echo "Downloading gaming related software..."
	yes | sudo dnf install steam
	yes | sudo dnf install discord
	yes | sudo dnf install lutris
	yes | sudo dnf install bottles
else
	echo ""
fi

#Battery
if [[ $BATTERY == "y" || $BATTERY == "Y" ]]; then
	echo "Installing power management software..."
	#Powertop
	yes | sudo dnf install powertop
	#TLP
	yes | sudo dnf install tlp
	yes | sudo dnf remove power-profiles-daemon
	sudo systemctl enable tlp.service
	sudo systemctl mask systemd-rfkill.service
	sudo systemctl mask systemd-rfkill.socket
	sudo tlp start
else
	echo ""
fi

#Drivers
if [[ $DRIVERS == "y" || $DRIVERS == "Y" ]]; then
	echo "Installing NVidia drivers..."
	yes | sudo dnf upgrade --refresh
	yes | sudo dnf install akmod-nvidia -y
	yes | sudo dnf install xorg-x11-drv-nvidia-cuda
	echo "Your system needs to reboot for changes to take place. Reboot? (y/n)"
	read REBOOTN
		if [[ $REBOOTN == "Y" || $REBOOTN == "y" ]]; then
			echo "Your system will now reboot."
			sudo reboot now
		else
			echo "Your system will not reboot."
		fi
	else
		echo ""
	fi

echo "Thank you for using my autoconfig!"
