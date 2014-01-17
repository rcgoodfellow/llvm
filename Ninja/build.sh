#!/bin/sh

if [ "$#" -lt 4 ]
then
  echo "usage : buildit <libc++_include_dir> <libc++_lib_dir> <libc++abi_include_dir> <libc++abi_lib_dir>"
  exit 1
fi

export LDFLAGS="-L$2 -lc++ -L$4 -lc++abi"
cmake -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_C_COMPILER=clang -DLLVM_ENABLE_CXX11=ON -DCMAKE_CXX_FLAGS="-stdlib=libc++ -I$1 -I$3" -G Ninja ..
