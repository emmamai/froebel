#!/bin/sh

source common/colors.sh
source common/log.sh
source common/build_target.conf

if [ -f .froebel_bootstrap ]; then
    export PATH=`pwd`/bin:$PATH

    export FBUILD_BOOTSTRAP=no
    export FBUILD_REPO=`pwd`/packages
    export froebelroot=`pwd`
    export TARGET_ARCH=`uname -m`
    fbuild="mksh $froebelroot/common/fbuild_lite.sh"
fi

log ${c_yellow}\#\# Froebel Build System${c_reset}
log run by `whoami`@`hostname` on `uname -s -m -r` at `date`

if [ "x$HOST_TRIPLE" = "x" ]; then
    export HOST_TRIPLE="$HOST_TRIPLE_GUESS"
    echo "Host triple has been guessed as ${HOST_TRIPLE}"
    echo "If this is not correct, please set this in build_target.conf"
fi

basepkgs="filesystem musl linux-headers libcxxabi-headers libcxx-headers compiler-rt musl mksh sbase ubase libunwind libcxxabi libcxx llvm zlib ncurses clang lld netbsd-csu libressl curl"

for pkg in $basepkgs; do
    $fbuild $pkg
    if [ $? != 0 ]; then
        exit 1;
    fi
done

export tmproot="/tmp/fbuild-tmproot-`whoami`-microrootfs"
mkdir -p $tmproot

for pkg in $basepkgs; do
    for localpkg in "$FBUILD_REPO"/"$pkg"_*.pkg; do
        log "installing $localpkg to tmproot"
        #opkg -o $tmproot -V0 install $localpkg
        tar -xJf $localpkg -C $tmproot
    done
    rm -r $tmproot/META
done



PV=$(which pv)
if [ $? = 0 ]; then
    pkgsize=$(du -sk "$tmproot" | cut -f 1)
    tar -cf - -C $tmproot . | pv -p -s ${pkgsize}k | xz -z > "froebel_micro_rootfs_$(date '+%Y%m%d').tar.gz"
else
    log "archiving..."
    tar -czf "froebel_micro_rootfs_$(date '+%Y%m%d').tar.gz" -C $tmproot .
fi


log "removing tmproot..."
rm -rf $tmproot
log "done"