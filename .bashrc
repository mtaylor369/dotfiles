#!/usr/bin/env bash
#
# .bashrc
#
# Initialise a Bash interactive shell.
#

# If the shell is not running interactively, don't do anything.
[[ "$-" =~ 'i' ]] || return 0

# Make sure the following environment variables are set.
: "${XDG_CONFIG_HOME:="${HOME}/.config"}"
: "${XDG_STATE_HOME:="${HOME}/.local/state"}"

# Enable the Emacs-like editing mode.
set -o emacs

# Enable the readline horizontal scrolling mode.
bind 'set horizontal-scroll-mode on'

# Set up the history file.
HISTFILE="${XDG_STATE_HOME}/bash/history"
(umask 022 && mkdir -p "${HISTFILE%/*}")
HISTCONTROL='ignoredups:ignorespace'
HISTSIZE=250000
shopt -s histappend

# Set up the PS1 prompt.
case "${TERM-}" in
	'xterm-color'|*'-256color')
		PS1='\[\e[1;32m\]\u@\h\[\e[0m\]:\[\e[1;34m\]\w\[\e[0m\]\n\$ '
		;;
	*)
		PS1='\u@\h:\w\n\$ '
		;;
esac

# Source the shell aliases script.
if [[ -f "${XDG_CONFIG_HOME}/sh/aliases" ]]; then
	. "${XDG_CONFIG_HOME}/sh/aliases"
fi
