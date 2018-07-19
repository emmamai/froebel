#!/bin/sh

source common/colors.sh
source common/build.conf

check_var_set() {
    var=$1
    eval res="\$$var"
    if [ "$res" = "" ]; then
        log ${c_red}"error: $var not set in recipe!"
        exit 1
    else
        log $c_blue$var: $c_reset$res
    fi
}

set_default() {
    var=$1
    eval res="\$$var"
    if [ "$res" = "" ]; then
        eval $var="$2"
    fi 
}

do_fetch() {
    mkdir -p $srcdir
    log ${c_green}"fetch package sources..."${c_reset}
    filename=`echo $src | sed -e s/.*\\\///`
    if [ ! -f $srcdir/$filename ]; then
        echo filename is $filename
        wget $src -O $srcdir/$filename
    fi
    log ${c_green}"ok"${c_reset}
}

do_unpack() {
    pushd $srcdir
    case "$filename" in
        *.tar.gz)
            tar -xzf $filename
            ;;
        *.tgz)
            tar -xzf $filename
            ;;
        *.tar.xz)
            tar -xJf $filename
            ;;
        *)
            log $c_red"Error unpacking: unknown filetype for $filename"$c_reset
            ;;
    esac
    popd
}

do_test() {
    echo "no tests specified for this package"
}

do_package() {
    mkdir -p $pkgdir/CONTROL
    echo "Package: $pkgname" > $pkgdir/CONTROL/control
    echo "Version: $pkgver-$pkgrev" >> $pkgdir/CONTROL/control
    echo "Architecture: $arch" >> $pkgdir/CONTROL/control
    echo "Maintainer: $maintainer" >> $pkgdir/CONTROL/control
    echo "Description: " $desc >> $pkgdir/CONTROL/control
    opkg-build -c $pkgdir $FBUILD_REPO
    rm -r pkg
    rm -r src
}

set_default FBUILD_REPO `pwd`/packages
set_default TARGET_ARCH `uname -m`
arch=$TARGET_ARCH

mkdir -p $FBUILD_REPO

if [ ! -d recipes/$1/ ]; then
    echo -e ${c_red}"error: no recipe for $1!"
    exit 1
fi

cd recipes/$1/

source ../../common/log.sh

srcdir=`pwd`/src
pkgdir=`pwd`/pkg

source ./recipe

log $c_yellow"## fbuild lite: building package \"$1\" for $TARGET_ARCH\n"$c_reset
log $c_green"checking recipe..."

check_var_set pkgname
check_var_set pkgver
check_var_set pkgrev

check_var_set src

log $c_green"ok!\n"$c_reset

target="${pkgname}_${pkgver}-${pkgrev}_${arch}.ipk"

if [ -f $FBUILD_REPO/$target ]; then
    log -e $c_green"package \"$pkgname\" is already up to date!\n\n"$c_reset
    exit 0
fi

do_fetch
do_unpack
do_build
do_test
do_install
if [ "$FBUILD_BOOTSTRAP" = "yes" ]; then
    do_bootstrap_install
fi
do_package
