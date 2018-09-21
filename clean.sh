#!/bin/sh

rm -r bin doc hostpkgs packages include lib man share usr build.log .froebel_bootstrap
cd recipes

for pkg in *; do
    pushd $pkg
    rm -rf pkg src build.log
    popd 
done