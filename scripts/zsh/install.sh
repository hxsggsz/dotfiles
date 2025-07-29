#!/usr/bin/env bash

install_zsh() {
  echo "installing zsh"
  sudo apt install zsh
}

install_oh_my_zsh_plugins() {
  echo "installing oh my zsh plugins"
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
}

install_oh_my_zsh() {
  echo "installing oh my zsh"
  install_oh_my_zsh_plugins
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  echo "installed oh my zsh successfully"
}

setup_zsh_and_omz() {
  install_zsh
  install_oh_my_zsh
}
