#!/usr/bin/env bash
#
# .bash_profile
#
# Initialise a Bash login shell.
#

# Source the login shell startup script.
if [[ -f "${HOME}/.profile" ]]; then
	. "${HOME}/.profile"
fi

# Source the Bash interactive shell startup script.
if [[ -f "${HOME}/.bashrc" ]]; then
	. "${HOME}/.bashrc"
fi
