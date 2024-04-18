#!/bin/bash

# Check for internet connection
if ping -q -c 1 -W 1 google.com >/dev/null; then
    version=$(cat ~/dotfiles/.version/version | sed 's/^v//')
    online=$(curl -s https://raw.githubusercontent.com/dianaw353/starter-dotfile/main/.version/version?ref_type=heads | sed 's/^v//')
    echo "Version: $version"
    echo "Online: $online"
    if (( $(echo "$online > $version" | bc -l) )); then
        # Update available
        echo "0"
    else
        # No update available
        echo "1"
    fi
else
    # Network is down
    echo "1"
fi
