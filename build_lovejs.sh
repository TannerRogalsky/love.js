#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"

mkdir -p build/debug build/release

source ~/git/emsdk/emsdk_env.sh

#(
  # cd build/debug
  # emcmake cmake /Users/dkhachat/git/megasource -DLOVE_JIT=0 -DCMAKE_BUILD_TYPE=Debug
  # emmake make -j 6
  # cp love/love.js* ../../src/debug
  # cp love/pthread-main.js ../../src/debug
#)

(
  cd build/release
  emcmake cmake /Users/dkhachat/git/megasource -DLOVE_JIT=0 -DCMAKE_BUILD_TYPE=Release -DCMAKE_VERBOSE_MAKEFILE=ON
  emmake make -j 6
  cp love/love.js* ../../src/release
  cp love/love.wasm ../../src/release
  cp love/love.worker.js ../../src/release
  #cp love/pthread-main.js ../../src/release
)
