#!/usr/bin/env bash

readonly BUILD_DIR="build"

install_neovim_dependencies() {
  sudo apt install git tmux fzf build-essential cmake git pkg-config libtool g++ libunibilium4 libunibilium-dev \
    ninja-build gettext libtool libtool-bin autoconf automake unzip curl doxygen lua-term lua-term-dev luarocks || return 1
}

clone_neovim_from_github() {
  local target_dir="${1:-$HOME/neovim}"
  echo "Cloning neovim into $target_dir..."
  if [ -d "$target_dir" ]; then
    echo "Directory $target_dir already exists."
  fi

  git clone https://github.com/neovim/neovim "$target_dir"
  cd "$target_dir"
  git checkout stable
  echo "Neovim cloned and checked out to stable branch."
}

has_neovim_installed() {
  if [ -d "$BUILD_DIR" ]; then
    return 0
  else
    return 1
  fi
}

install_neovim() {
  if has_neovim_installed; then
    echo "already have neovim installed, removing it to install again"
    # removes the installed neovim
    make distclean
    # need to clean this folder if already have neovim installed
    rm -rf .deps build
  fi

  echo "installing neovim..."
  make CMAKE_BUILD_TYPE=RelWithDebInfomake CMAKE_BUILD_TYPE=RelWithDebInfo
  sudo make install
  echo "neovim installed successfully"
}

setup_neovim() {
  install_neovim_dependencies
  clone_neovim_from_github
  install_neovim
}
