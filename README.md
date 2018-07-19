froebel linux
=======

this repository is intended to contain the entire package repository and build system for froebel linux.

from within froebel, you can go to any recipe directory and type 'fbuild' to build the package, or use the 'build_all.sh' and 'build_iso_*.sh' scripts to build a full system.

you can also build froebel from systems that are not running froebel. you will need to be running in a unix-like environment with a working c/c++ compiler, and gnu-compatible make.

the bootstrap will build the following tools, and install them within the bin subdirectory of this tree:

- mksh (mirbsd korn shell)
- opkg-utils
- cmake
- llvm
- clang

you can then use the scripts at the root of the directory to build a full froebel repo, a froebel iso, etc.

the build system is currently messy and does not dependency check, so building packages manually may be fraught with difficulty.