#!/bin/bash

# This script toggles the input method conditionally
# Disables IME toggle when in game

window_class=$(hyprctl activewindow | grep "class:")

# Check if the class does not contain "steam_app"
if [[ $window_class != *"steam_app_"* ]]; then
	# Toggle fcitx input method
	fcitx5-remote -t
fi
