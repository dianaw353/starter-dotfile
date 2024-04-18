#!/bin/bash
#  ___           _        _ _   _   _           _       _
# |_ _|_ __  ___| |_ __ _| | | | | | |_ __   __| | __ _| |_ ___  ___
#  | || '_ \/ __| __/ _` | | | | | | | '_ \ / _` |/ _` | __/ _ \/ __|
#  | || | | \__ \ || (_| | | | | |_| | |_) | (_| | (_| | ||  __/\__ \
# |___|_| |_|___/\__\__,_|_|_|  \___/|.__/ \__,_|\__,_|\__\___||___/
#                                    |_|
# by Stephan Raabe (2024)
# -----------------------------------------------------

# Define threshholds for color indicators
THRESHOLD_GREEN=0
THRESHOLD_YELLOW=25
THRESHOLD_RED=100

# Detect package manager
_detect_package_manager() {
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

package_manager=$(_detect_package_manager)

# Calculate available updates using the detected package manager
if [ "$package_manager" = "None of the specified package managers are installed." ]; then
    echo "No package manager found."
    exit 1
fi

if [ "${package_manager%-bin}" = "$package_manager" ]; then
  gum log --structured --level debug "Syncing packages..."
  sudo $package_manager -Sy --noconfirm
  gum log --structured --level debug "Checking for available package updates..."
  num_updates=$(pacman -Qu | wc -l)
  if [ "$num_updates" -gt "0" ]; then
    gum log --structured --level debug "$num_updates packages have updates available."
  else
    gum log --structured --level debug "No package updates available."
  fi
fi

updates_all_packages=$((num_updates))

# Output in JSON format for Waybar Module custom-updates
css_class="green"

if [ "$updates_all_packages" -gt $THRESHOLD_YELLOW ]; then
    css_class="yellow"
fi

if [ "$updates_all_packages" -gt $THRESHOLD_RED ]; then
    css_class="red"
fi

if [ "$updates_all_packages" -gt $THRESHOLD_GREEN ]; then
    printf '{"text": "%s", "alt": "%s", "tooltip": "%s Updates", "class": "%s"}' "$updates_all_packages" "$updates_all_packages" "$updates_all_packages" "$css_class"
else
    printf '{"text": "0", "alt": "0", "tooltip": "0 Updates", "class": "green"}'
fi

# Confirm Start
if gum confirm "DO YOU WANT TO START THE UPDATE NOW?" ;then
    echo
    echo ":: Update started."
    if [ "$package_manager" = "None of the specified package managers are installed." ]; then
        echo "No package manager found."
        exit 1
    fi

    if [ "${package_manager%-bin}" = "$package_manager" ]; then
        eval "$package_manager" -Syu
    else
        eval "$package_manager" -Syu
    fi

elif [ $? -eq 130 ]; then
        exit 130
else
    echo
    echo ":: Update canceled."
    exit;
fi

# add backups
