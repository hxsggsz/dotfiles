#!/usr/bin/env bash

source ./github/setup.sh
source ./neovim/install.sh
source ./lazygit/install.sh
source ./zsh/install.sh
source ./nvm-zsh/install.sh

# Define your tools and functions
tools=("Git" "Neovim" "Lazygit" "Zsh" "Nvm" "All")
function install_all() {
  setup_git
  setup_neovim
  install_lazygit
  install_nvm_with_zsh
  setup_zsh_and_omz
}

# Initialize selection array
selected=()
for i in "${!tools[@]}"; do
  selected[$i]=""
done

# Display menu and handle user input
msg=""
while true; do
  clear
  echo "Select tools to install (press number to toggle, ENTER to confirm):"
  for i in "${!tools[@]}"; do
    printf "%2d%s) %s\n" $((i + 1)) "${selected[i]:- }" "${tools[i]}"
  done
  [[ -n "$msg" ]] && echo "$msg"
  read -p "Your choice: " choice

  if [[ -z "$choice" ]]; then
    break
  elif [[ "$choice" =~ ^[1-${#tools[@]}]$ ]]; then
    ((choice--))
    if [[ "${tools[$choice]}" == "All" ]]; then
      # Option 1: Mark all checkboxes
      for i in "${!selected[@]}"; do
        selected[$i]="+"
      done
      msg="All tools selected"
    else
      if [[ "${selected[$choice]}" == "+" ]]; then
        selected[$choice]=""
        msg="${tools[$choice]} deselected"
      else
        selected[$choice]="+"
        msg="${tools[$choice]} selected"
      fi
    fi
  else
    msg="Invalid choice: $choice"
  fi
done

# Call installation functions for selected tools
echo "Installing selected tools..."
for i in "${!selected[@]}"; do
  if [[ "${selected[$i]}" == "+" ]]; then
    case "${tools[$i]}" in
    "Git") setup_git ;;
    "Neovim") setup_neovim ;;
    "Lazygit") install_lazygit ;;
    "Zsh") install_oh_my_zsh ;;
    "Nvm") install_nvm_with_zsh ;;
    "Docker") install_docker ;;
    "All") install_all ;;
    esac
  fi
done

echo "Installation completed."
