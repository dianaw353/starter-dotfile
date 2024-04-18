#!/bin/bash
clear
cat <<"EOF"
  ____ _                                
 / ___| | ___  __ _ _ __    _   _ _ __  
| |   | |/ _ \/ _` | '_ \  | | | | '_ \ 
| |___| |  __/ (_| | | | | | |_| | |_) |
 \____|_|\___|\__,_|_| |_|  \__,_| .__/ 
                                 |_|    

EOF

sudo pacman -Rns $(pacman -Qtdq)
_detectPackageManager() {
  local package_managers=("yay" "yay-bin" "yay-git" "aura" "aura-bin" "aura-git" "paru" "paru-bin" "paru-git")
  for package_manager in "${package_managers[@]}"; do
    if command -v $package_manager &> /dev/null; then
      echo "$package_manager"
      return 0
    fi
  done
  echo "None of the specified package managers are installed."
  return 1
}

package_manager=$(_detectPackageManager)
eval "$package_manager" -Scc
