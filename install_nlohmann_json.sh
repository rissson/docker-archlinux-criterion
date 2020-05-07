#! /usr/bin/env bash

set -o pipefail -e

[[ -z "$1" ]] && echo "You must specify a user name" && exit 1
AUR_USER=$1

# Create the user
useradd -m ${AUR_USER}

# Erase user password
echo "${AUR_USER}:" | chpasswd -e

# Install base-devel without systemd
pkgs=$(pacman -S base-devel --print-format '%n ');pkgs=${pkgs//systemd/};pkgs=${pkgs//$'\n'/}
pacman --needed --noprogressbar --noconfirm -S $pkgs git

# Passwordless for $AUR_USER
echo "$AUR_USER      ALL = NOPASSWD: ALL" >> /etc/sudoers

# Use all cores when building packages
sed -i 's,#MAKEFLAGS="-j2",MAKEFLAGS="-j$(nproc)",g' /etc/makepkg.conf
# Don't compress packages
sed -i "s,PKGEXT='.pkg.tar.xz',PKGEXT='.pkg.tar',g" /etc/makepkg.conf

pacman --needed --noprogressbar --noconfirm -S cmake

# Install criterion
su ${AUR_USER} -c "cd; git clone https://aur.archlinux.org/nlohmann-json-git.git"
# Disabling checks as they fail on the pipeline
su ${AUR_USER} -c "cd; cd nlohmann-json-git; makepkg -src --nocheck"
pushd /home/${AUR_USER}/nlohmann-json-git/
pacman -U *.pkg.tar --noprogressbar --noconfirm
popd
rm -rf /home/${AUR_USER}/nlohmann-json-git
