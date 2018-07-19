#!/bin/sh

touch .froebel_bootstrap

source common/colors.sh
source common/log.sh

mkdir -p bin

export PATH=`pwd`/bin:$PATH

export FBUILD_BOOTSTRAP=yes
export FBUILD_REPO=`pwd`/hostpkgs
export froebelroot=`pwd`
export TARGET_ARCH=`uname -m`
fbuild='sh ./common/fbuild_lite.sh'

log ${c_yellow}\#\# Froebel Bootstrap${c_reset}
log run by `whoami`@`hostname` on `uname -s -m -r` at `date`

pkglist="opkg-utils mksh cmake llvm clang"

for pkg in $pkglist; do
    $fbuild $pkg
done
