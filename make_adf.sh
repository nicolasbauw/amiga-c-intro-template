#!/bin/zsh
[ -f intro.adf ] || xdftool intro.adf format Intro ffs + boot install
xdftool intro.adf delete intro
xdftool intro.adf write intro