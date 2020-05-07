FROM archlinux/base
MAINTAINER Marc 'risson' Schmitt <marc.schmitt@risson.space>

RUN pacman --noconfirm --noprogressbar -Syyu

RUN pacman --noconfirm --noprogressbar --needed -S make gcc autoconf automake \
            autoconf-archive bison clang cmake ctags flex gcc-libs gdb glibc \
            boost \
            llvm valgrind python python-yaml python-termcolor doxygen \
            gtest

COPY ./install_criterion.sh /usr/bin/install_criterion
RUN install_criterion docker
