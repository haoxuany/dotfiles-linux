#!/usr/bin/env bash

# Options
shutdown='⏻'
reboot='󰜉'
lock=''
suspend=''
logout='󰍃'

rofi_cmd() {
	rofi -dmenu \
		-hover-select -me-select-entry '' -me-accept-entry MousePrimary \
		-theme $HOME/.config/rofi/powermenu.rasi
}

run_rofi() {
	echo -e "$lock\n$suspend\n$logout\n$reboot\n$shutdown" | rofi_cmd
}

chosen="$(run_rofi)"
case ${chosen} in
    $shutdown)
		systemctl poweroff
        ;;
    $reboot)
		systemctl reboot
        ;;
    $lock)
		hyprlock
        ;;
    $suspend)
		mpc -q pause
		amixer set Master mute
		systemctl suspend
        ;;
    $logout)
		hyprlock
        ;;
esac
