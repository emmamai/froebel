#!/bin/sh

rm -r bin doc hostpkgs include lib man share usr build.log .froebel_bootstrap
cd recipes

for pkg in *; do
    pushd $pkg
    rm -r pkg src build.log
    popd 
done