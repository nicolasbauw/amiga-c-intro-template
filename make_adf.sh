#!/bin/zsh
[ -f intro.adf ] || xdftool intro.adf format Intro ffs + boot install
xdftool intro.adf delete intro
xdftool intro.adf makedir libs
xdftool intro.adf makedir assets
xdftool intro.adf write assets/RED.MOD assets
xdftool intro.adf write libs/ptreplay.library libs
xdftool intro.adf write intro