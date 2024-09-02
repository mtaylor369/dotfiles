#!/bin/sh
#
# .profile
#
# Initialise a login shell.
#
umask 022

# Set up the default locale and character encoding.
export LANG='en_GB.UTF-8'
export LC_ALL="${LANG}"

# Set up XDG directories.
export XDG_CACHE_HOME="${HOME}/.cache"
export XDG_CONFIG_HOME="${HOME}/.config"
export XDG_DATA_HOME="${HOME}/.local/share"
export XDG_STATE_HOME="${HOME}/.local/state"

if [ -z "${XDG_RUNTIME_DIR-}" ]; then
	uid="$(id -u)"

	if [ -n "${uid}" ]; then
		export XDG_RUNTIME_DIR="/tmp/${uid}-runtime-dir"

		if [ -d "${XDG_RUNTIME_DIR}" ]; then
			chmod 0700 "${XDG_RUNTIME_DIR}"
		else
			mkdir -m 0700 "${XDG_RUNTIME_DIR}"
		fi
	fi

	unset uid
fi

# Add the user's bin directory to the PATH environment variable.
bin_dir="${HOME}/.local/bin"

if [ -d "${bin_dir}" ]; then
	case "${PATH-}" in
		"${bin_dir}:"*|*":${bin_dir}:"*|*":${bin_dir}"|"${bin_dir}")
			;;
		*)
			export PATH="${bin_dir}${PATH:+":${PATH}"}"
			;;
	esac
fi

unset bin_dir

# Set the path to the script that initialises an interactive shell.
if [ -f "${XDG_CONFIG_HOME}/sh/shrc" ]; then
	export ENV="${XDG_CONFIG_HOME}/sh/shrc"
fi

# If installed, set vim(1) as the default text editor; otherwise, use vi(1).
if command -v vim >/dev/null; then
	if [ -f "${XDG_CONFIG_HOME}/vim/vimrc" ]; then
		export VIMINIT="source ${XDG_CONFIG_HOME}/vim/vimrc"
	fi

	export VISUAL='vim'
else
	export VISUAL='vi'
fi

export EDITOR="${VISUAL}"

# If installed, set less(1) as the default pager; otherwise, use more(1).
if command -v less >/dev/null; then
	export LESSHISTFILE='/dev/null'
	export PAGER='less'
else
	export PAGER='more'
fi

# If supported, set the colours the ls(1) command will use.
if command ls --color='auto' >/dev/null 2>&1; then
	LS_COLORS='di=1;34'
	LS_COLORS="${LS_COLORS}:ln=1;36"
	LS_COLORS="${LS_COLORS}:so=1;35"
	LS_COLORS="${LS_COLORS}:pi=33"
	LS_COLORS="${LS_COLORS}:ex=1;32"
	LS_COLORS="${LS_COLORS}:bd=1;33;40"
	LS_COLORS="${LS_COLORS}:cd=1;33;40"
	LS_COLORS="${LS_COLORS}:su=1;32;40"
	LS_COLORS="${LS_COLORS}:sg=1;32;40"
	LS_COLORS="${LS_COLORS}:tw=1;34;40"
	LS_COLORS="${LS_COLORS}:ow=1;34;40"
	LS_COLORS="${LS_COLORS}:mi=1;31"
	export LS_COLORS
elif command ls -G /dev/null >/dev/null 2>&1; then
	export LSCOLORS='ExGxFxdxCxDaDaCaCaEaEa'
fi

# Set up environment variables for specific operating systems.
case "$(uname -s)" in
	'OpenBSD')
		if [ -f "${XDG_CONFIG_HOME}/mail/mailrc" ]; then
			export MAILRC="${XDG_CONFIG_HOME}/mail/mailrc"
		fi

		export MBOX="${XDG_DATA_HOME}/mail/mbox"
		mkdir -p "${MBOX%/*}"

		if [ -f "${XDG_CONFIG_HOME}/nex/nexrc" ]; then
			export NEXINIT="source ${XDG_CONFIG_HOME}/nex/nexrc"
		fi
		;;
esac
