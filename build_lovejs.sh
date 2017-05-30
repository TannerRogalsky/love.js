#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"

mkdir -p build/debug build/release

source ~/code/c/emsdk_portable/emsdk_env.sh

(
  cd build/debug
  emcmake cmake /Users/tanner/code/c/love_11/megasource -DLOVE_JIT=0 -DCMAKE_BUILD_TYPE=Debug
  emmake make -j 6
  cp love/love.js* ../../src/debug
  cp love/pthread-main.js ../../src/debug
)

(
  cd build/release
  emcmake cmake /Users/tanner/code/c/love_11/megasource -DLOVE_JIT=0 -DCMAKE_BUILD_TYPE=Release
  emmake make -j 6
  cp love/love.js* ../../src/release
  cp love/pthread-main.js ../../src/release
)
