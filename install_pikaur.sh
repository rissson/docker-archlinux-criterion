#! /usr/bin/env bash

set -o pipefail -e

[[ -z "$1" ]] && echo "You must specify a user name" && exit 1
AUR_USER=$1

# Install pikaur dependencies
pacman --noconfirm --noprogressbar --needed -S python3 pyalpm

# Create the user
useradd -m ${AUR_USER}

# Erase user password
echo "${AUR_USER}:" | chpasswd -e

# Install base-devel without systemd
pkgs=$(pacman -S base-devel --print-format '%n ');pkgs=${pkgs//systemd/};pkgs=${pkgs//$'\n'/}
pacman --needed --noprogressbar --noconfirm -S $pkgs

# Passwordless for $AUR_USER
echo "$AUR_USER      ALL = NOPASSWD: ALL" >> /etc/sudoers

# Use all cores when building packages
sed -i 's,#MAKEFLAGS="-j2",MAKEFLAGS="-j$(nproc)",g' /etc/makepkg.conf
# Don't compress packages
sed -i "s,PKGEXT='.pkg.tar.xz',PKGEXT='.pkg.tar',g" /etc/makepkg.conf

# Install pikaur
su ${AUR_USER} -c "cd; git clone https://aur.archlinux.org/pikaur.git"
su ${AUR_USER} -c "cd; cd pikaur; makepkg -frsic"
rm -rf /home/${AUR_USER}/pikaur

# Do a pikaur system update
su $AUR_USER -c "pikaur -Syyu --noprogressbar --noconfirm --needed"
