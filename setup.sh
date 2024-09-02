#!/bin/sh
#
# setup.sh
#
# Set up the current user's home directory and install dotfiles.
#
# Usage: sh setup.sh
#
set -eu
umask 022
: "${DOTFILES_DIR:="${HOME}/Projects/dotfiles"}"
readonly DOTFILES_DIR

error_msg() {
	printf '%s: %s\n' "${0##*/}" "$*" >&2
}

msg() {
	printf '==> %s\n' "$*" >&2
}

get_os_name() (
	kernel_name="$(uname -s)"

	if [ "${kernel_name}" = 'Linux' ]; then
		for file in /etc/os-release /usr/lib/os-release; do
			[ -f "${file}" ] || continue
			unset NAME

			if . "${file}" 2>/dev/null && [ -n "${NAME-}" ]; then
				printf '%s\n' "${NAME}"
				return 0
			fi
		done
	fi

	printf '%s\n' "${kernel_name}"
)

find_path() (
	exec_name="$1"

	while IFS='' read -r dir; do
		[ -n "${dir}" ] || continue
		file="${dir}/${exec_name}"

		if [ -f "${file}" ] && [ -x "${file}" ]; then
			printf '%s\n' "${file}"
			return 0
		fi
	done <<-EOF
	$(printf '%s\n' "${PATH-}" | tr ':' '\n')
	EOF

	return 1
)

install_file() (
	mode="$1"
	file="$2"
	src_file="${DOTFILES_DIR}/${file}"

	if [ ! -e "${src_file}" ]; then
		error_msg "${src_file}: no such file exists"
		exit 1
	fi

	if [ ! -f "${src_file}" ] || [ -h "${src_file}" ]; then
		error_msg "${src_file}: this path is not a regular file"
		exit 1
	fi

	dest_file="${HOME}/${file}"

	if [ -e "${dest_file}" ]; then
		if [ ! -f "${dest_file}" ] || [ -h "${dest_file}" ]; then
			error_msg "cannot install ${dest_file}:" \
			    'existing path is not a regular file'
			exit 1
		fi

		if cmp "${src_file}" "${dest_file}" >/dev/null 2>&1; then
			return 0
		fi
	else
		dest_dir="$(dirname "${dest_file}")"
		mkdir -p "${dest_dir}"
	fi

	cp "${src_file}" "${dest_file}"
	chmod "${mode}" "${dest_file}"
	printf 'Installed: %s\n' "${dest_file}" >&2
)

uid="$(id -u)"

if [ "${uid}" = '0' ]; then
	error_msg 'this script must be run as a non-root user'
	exit 1
fi

if [ ! -d "${DOTFILES_DIR}" ]; then
	error_msg "${DOTFILES_DIR}: no such directory exists"
	exit 1
fi

os_name="$(get_os_name)"
readonly os_name

msg "Setting up ${HOME}..."

. "${DOTFILES_DIR}/.config/user-dirs.dirs"
mkdir -p "${XDG_DESKTOP_DIR:-"${HOME}/Desktop"}"
mkdir -p "${XDG_DOCUMENTS_DIR:-"${HOME}/Documents"}"
mkdir -p "${XDG_DOWNLOAD_DIR:-"${HOME}/Downloads"}"
mkdir -p "${XDG_MUSIC_DIR:-"${HOME}/Music"}"
mkdir -p "${XDG_PICTURES_DIR:-"${HOME}/Pictures"}"
mkdir -p "${XDG_PUBLICSHARE_DIR:-"${HOME}/Public"}"
mkdir -p "${XDG_TEMPLATES_DIR:-"${HOME}/Templates"}"
mkdir -p "${XDG_VIDEOS_DIR:-"${HOME}/Videos"}"
mkdir -p "${HOME}/Projects"

case "${os_name}" in
	'OpenBSD')
		msg "Setting up ${HOME} for OpenBSD..."

		if colorls_path="$(find_path colorls)"; then
			dest_file="${HOME}/.local/bin/ls"

			if [ ! -h "${dest_file}" ]; then
				mkdir -p "${dest_file%/*}"
				ln -s "${colorls_path}" "${dest_file}"
			fi
		fi

		if [ -f "${HOME}/mbox" ]; then
			dest_file="${HOME}/.local/share/mail/mbox"
			mkdir -p "${dest_file%/*}"
			mv "${HOME}/mbox" "${dest_file}"
		fi

		if [ -f "${HOME}/.xsession-errors" ]; then
			dest_file="${HOME}/.local/state/X11/Xsession-errors"
			mkdir -p "${dest_file%/*}"
			mv "${HOME}/.xsession-errors" "${dest_file}"
		fi

		rm -f "${HOME}/.Xdefaults"
		rm -f "${HOME}/.cshrc"
		rm -f "${HOME}/.cvsrc"
		rm -f "${HOME}/.login"
		rm -f "${HOME}/.mailrc"
		;;
esac

msg 'Installing dotfiles...'

install_file 0644 .config/user-dirs.dirs
install_file 0644 .config/user-dirs.locale
install_file 0755 .local/bin/install-otf-fonts
install_file 0755 .local/bin/install-ttf-fonts
install_file 0755 .local/bin/launcher
install_file 0755 .local/bin/lscolors
install_file 0755 .local/bin/sf

case "${os_name}" in
	'OpenBSD')
		msg 'Installing dotfiles for OpenBSD...'

		install_file 0644 .config/mail/mailrc
		install_file 0644 .config/nex/nexrc
		install_file 0755 .local/bin/lsfs
		install_file 0755 .local/bin/setup-openbsd
		install_file 0755 .local/bin/vol
		;;
esac

if command -v bash >/dev/null; then
	msg 'Installing dotfiles for bash(1)...'

	install_file 0644 .bash_profile
	install_file 0644 .bashrc
fi

if command -v cwm >/dev/null; then
	msg 'Installing dotfiles for cwm(1)...'

	install_file 0644 .config/X11/Xresources
	install_file 0755 .config/X11/Xsession
	install_file 0644 .config/cwm/cwmrc
	install_file 0644 .config/fontconfig/fonts.conf
	install_file 0644 .config/gtk-3.0/bookmarks
	install_file 0644 .config/gtk-3.0/settings.ini
	install_file 0755 .local/bin/xscreenshot
	install_file 0755 .local/bin/xstatus
	install_file 0644 .local/share/X11/bitmaps/checkboard-16x16.xbm
	install_file 0644 .local/share/X11/bitmaps/checkboard-8x8.xbm
fi

if command -v firefox >/dev/null; then
	msg 'Installing dotfiles for firefox(1)...'

	install_file 0755 .local/bin/setup-firefox
fi

if command -v git >/dev/null \
    && [ -f "${DOTFILES_DIR}/.config/git/config.local" ]; then
	msg 'Installing dotfiles for git(1)...'

	install_file 0644 .config/git/config
	install_file 0644 .config/git/config.local
fi

if command -v krita >/dev/null; then
	msg 'Installing dotfiles for krita(1)...'

	install_file 0755 .local/bin/krita
fi

if command -v ksh >/dev/null; then
	msg 'Installing dotfiles for ksh(1)...'

	install_file 0644 .config/ksh/kshrc
fi

if command -v lmms >/dev/null; then
	msg 'Installing dotfiles for lmms(1)...'

	if [ ! -f "${HOME}/.config/lmms/lmmsrc.xml" ]; then
		install_file 0644 .config/lmms/lmmsrc.xml
	fi

	install_file 0755 .local/bin/lmms
fi

if command -v mpv >/dev/null; then
	msg 'Installing dotfiles for mpv(1)...'

	install_file 0644 .config/mpv/mpv.conf
fi

if command -v sh >/dev/null \
    || command -v bash >/dev/null \
    || command -v ksh >/dev/null; then
	msg 'Installing dotfiles for sh(1)...'

	install_file 0644 .config/sh/aliases
	install_file 0644 .config/sh/shrc
fi

if command -v tmux >/dev/null; then
	msg 'Installing dotfiles for tmux(1)...'

	install_file 0644 .config/tmux/tmux.conf
	install_file 0755 .local/bin/tmux
fi

if command -v vim >/dev/null; then
	msg 'Installing dotfiles for vim(1)...'

	install_file 0644 .config/vim/vimrc
fi
