#!/usr/bin/env bash
set -e
#EMSDK_VERSION="tot-upstream"
EMSDK_VERSION="latest"

c_files="$(ls ./native/*.c)"
exported_functions='-s EXPORTED_FUNCTIONS=["_malloc","_free","_h264bsdAlloc","_h264bsdFree","_h264bsdInit","_h264bsdDecode","_h264bsdShutdown"]'
exported_runtime_methods='-s EXPORTED_RUNTIME_METHODS=[getValue]'
EXPORT_FLAGS="$exported_runtime_methods $exported_functions"

#######################################
# Ensures a repo is checked out.
# Arguments:
#   url: string
#   name: string
# Returns:
#   None
#######################################
ensure_repo() {
  local url name
  local "${@}"

  git -C ${name} pull || git clone ${url} ${name}
}

ensure_emscripten() {
  ensure_repo url='https://github.com/emscripten-core/emsdk.git' name='emsdk'
  pushd 'emsdk'
  ./emsdk update-tags
  ./emsdk install ${EMSDK_VERSION}
  ./emsdk activate ${EMSDK_VERSION}
  source ./emsdk_env.sh
  popd
}

build() {
    emcc $c_files -O3 -flto --memory-init-file 0 -s ENVIRONMENT='worker' -s NO_EXIT_RUNTIME=1 -s NO_FILESYSTEM=1 -s INVOKE_RUN=0 -s DOUBLE_MODE=0 -s ALLOW_MEMORY_GROWTH=1 -s MODULARIZE=1 -s EXPORT_ES6=1 -s SINGLE_FILE=1 $EXPORT_FLAGS -o ./src/TinyH264.js
}

main() {
  ensure_emscripten
  build
}

main
