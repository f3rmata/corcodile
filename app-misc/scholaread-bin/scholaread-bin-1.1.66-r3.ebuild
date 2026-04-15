# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit xdg-utils

DESCRIPTION="A helpful AI driven software that helps you do research."
HOMEPAGE="https://scholaread.com"
SRC_URI="https://cdn.scholaread.com/assets/pc-releases/${PV}/com/Scholaread-linux-amd64-${PV}.deb -> ${P}.deb"

S="${WORKDIR}"

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	x11-libs/gtk+:3
	dev-libs/nss
	x11-libs/libXScrnSaver
	x11-libs/libXtst
"

QA_PREBUILT="opt/Scholaread/*"

src_unpack() {
	ar x "${DISTDIR}/${P}.deb" || die
	tar -xf data.tar.xz || die
}

src_install() {
	cp -a opt usr "${ED}" || die

	fperms +x /opt/Scholaread/scholaread
	fperms 4755 /opt/Scholaread/chrome-sandbox

	insinto /usr/share/licenses/${PN}
	doins opt/Scholaread/LICENSE.electron.txt
}

pkg_postinst() {
	xdg_desktop_database_update
	xdg_icon_cache_update
	einfo "Optional runtime dependencies:"
	einfo "  x11-libs/libnotify (desktop notifications support)"
	einfo "  x11-misc/xdg-utils (open URLs in browser)"
	einfo "  app-crypt/libsecret (password storage support)"
	einfo "  app-accessibility/at-spi2-core (accessibility support)"
	einfo "  sys-apps/util-linux (UUID generation support)"
	einfo "  || ( dev-libs/libappindicator dev-libs/libayatana-appindicator ) (system tray icon support)"
}

pkg_postrm() {
	xdg_desktop_database_update
	xdg_icon_cache_update
}
