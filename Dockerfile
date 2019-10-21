FROM archlinux/base
MAINTAINER Marc 'risson' Schmitt <marc.schmitt@risson.space>

COPY ./install_pikaur /usr/bin/install_pikaur
RUN install_pikaur docker

RUN su docker -c "pikaur --noconfirm --noprogressbar --needed -S criterion"
