# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop optfeature systemd unpacker xdg

DESCRIPTION="Official sing-box desktop client for Linux"
HOMEPAGE="https://sing-box.sagernet.org/clients/desktop/ https://github.com/SagerNet/sing-box-for-desktop"
SRC_URI="
	amd64? ( https://github.com/SagerNet/sing-box/releases/download/v${PV}/SFL-${PV}-amd64.deb )
	arm64? ( https://github.com/SagerNet/sing-box/releases/download/v${PV}/SFL-${PV}-arm64.deb )
"
S="${WORKDIR}"

LICENSE="GPL-3+ BSD LGPL-2.1+ MIT OFL-1.1"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="suid"
REQUIRED_USE="elibc_glibc"
RESTRICT="strip"

RDEPEND="
	app-accessibility/at-spi2-core:2
	app-crypt/libsecret
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	dev-libs/wayland
	media-libs/alsa-lib
	media-libs/mesa[gbm(+)]
	net-print/cups
	sys-apps/dbus
	sys-apps/util-linux
	sys-auth/polkit
	elibc_glibc? ( >=sys-libs/glibc-2.25 )
	virtual/libudev
	x11-libs/cairo
	x11-libs/gtk+:3
	x11-libs/libdrm
	x11-libs/libnotify
	x11-libs/libX11
	x11-libs/libxcb
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libxkbcommon
	x11-libs/libXrandr
	x11-libs/libXScrnSaver
	x11-libs/libXtst
	x11-libs/pango
	x11-misc/xdg-utils
"

QA_PREBUILT="opt/sing-box/*"

src_prepare() {
	default

	# Keep the CLI package's /usr/bin/sing-box available.
	sed -i 's|<binary>sing-box</binary>|<binary>sing-box-desktop</binary>|' \
		usr/share/metainfo/io.nekohasekai.sfl.metainfo.xml || die
	gunzip usr/share/doc/sing-box/changelog.gz || die
}

src_install() {
	dodir /opt
	cp -a opt/sing-box "${ED}/opt/" || die
	dosym -r /opt/sing-box/sing-box /usr/bin/sing-box-desktop

	if use suid; then
		fowners root:root /opt/sing-box/chrome-sandbox
		fperms 4711 /opt/sing-box/chrome-sandbox
	fi

	domenu usr/share/applications/sing-box.desktop
	insinto /usr/share
	doins -r usr/share/{icons,metainfo,mime,polkit-1}

	systemd_dounit usr/lib/systemd/system/sing-box-daemon.service
	newinitd "${FILESDIR}/sing-box-daemon.initd" sing-box-daemon

	dodoc usr/share/doc/sing-box/changelog
}

pkg_postinst() {
	xdg_pkg_postinst

	einfo "Start the desktop daemon before launching sing-box-desktop:"
	einfo "  OpenRC:  rc-update add sing-box-daemon default"
	einfo "           rc-service sing-box-daemon start"
	einfo "  systemd: systemctl enable --now sing-box-daemon.service"
	einfo "On OpenRC, use rc-service to restart the daemon after upgrades."
	einfo "The application's system service repair/restart actions require systemd."
	einfo "A running polkit authentication agent is needed for privileged actions."
	if ! use suid; then
		einfo "Electron sandboxing requires unprivileged user namespaces."
		einfo "If these are disabled, enable the suid USE flag for the sandbox helper."
	fi

	optfeature "system tray integration" dev-libs/libayatana-appindicator
}
