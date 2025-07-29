#!/usr/bin/env bash

install_git() {
  sudo apt install git
}

generate_ssh_key() {
  local email="$1"
  echo "generating the SSH key with email -> $email"
  ssh-keygen -t rsa -b 4096 -C "$email"
}

show_ssh_key() {
  local email="$1"

  echo "showing the ssh key for email $email, add it on your github"
  local ssh_dir="${1:-$HOME/.ssh}"
  cd "$ssh_dir"
  more id_rsa.pub
  read -p "press Enter to continue"
}

setup_git() {
  install_git

  read -p "type your git's username: " username
  read -p "type your git's email: " email

  git config --global user.name "$username"
  git config --global user.email "$email"
  echo "setting up git with username -> $username and email -> $email"

  generate_ssh_key "$email"
  show_ssh_key "$email"
}
