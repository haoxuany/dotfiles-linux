#!/bin/bash

if hyprctl clients | grep -q "class: spotify"
then
	hyprctl dispatch focuswindow class:spotify
else
	hyprctl dispatch exec spotify-launcher
fi
