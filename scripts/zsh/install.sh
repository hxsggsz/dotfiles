#!/usr/bin/env bash

install_zsh() {
  sudo apt install zsh
}

install_oh_my_zsh_plugins() {
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
}

install_oh_my_zsh() {
  echo "installing oh my zsh"
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  echo "removing the default config file for zsh"
  rm -fr ~/.zshrc
}

setup_zsh_and_omz() {
  install_zsh
  install_oh_my_zsh
}
