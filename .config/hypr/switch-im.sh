#!/bin/bash

IM=$(fcitx5-remote -n)

case $IM in
	keyboard-us)
		fcitx5-remote -s mozc
		;;

	mozc)
		fcitx5-remote -s rime
		;;

	rime)
		fcitx5-remote -s keyboard-us
		;;
esac
