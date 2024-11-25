# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake xdg xdg-utils desktop

DESCRIPTION="An event management system for SAST."
HOMEPAGE="https://evento.sast.fun"

if [[ "${PV}" == 9999 ]] ; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/NJUPT-SAST/sast-evento.git"

else
	SRC_URI="https://github.com/NJUPT-SAST/sast-evento/archive/refs/tags/${PV}.tar.gz"
	S="${WORKDIR}/${P/_*}"
fi

LICENSE="MIT"
SLOT="0"

RESTRICT="network-sandbox"
DEPEND="
	sys-devel/gcc:14
	dev-qt/qtbase:6[network,opengl,widgets]
	sys-devel/gettext
	app-crypt/libsecret
	dev-libs/spdlog
	>=dev-libs/boost-1.84
	dev-libs/openssl
	dev-cpp/nlohmann_json
	dev-cpp/tomlplusplus
	sys-libs/liburing[static-libs]
	dev-build/autoconf
	dev-build/automake
	dev-build/autoconf-archive
	x11-libs/libxcb
	x11-libs/libXrender
	x11-libs/libxkbcommon
	media-fonts/noto[cjk]"
RDEPEND="${DEPEND}"
BDEPEND="
	virtual/pkgconfig"

src_configure() {
	local mycmakeargs=(
		-DSLINT_FEATURE_RENDERER_FEMTOVG=OFF
		-DSLINT_FEATURE_RENDERER_SKIA=ON
	)

	CC=/usr/x86_64-pc-linux-gnu/gcc-bin/14/gcc
	CXX=/usr/x86_64-pc-linux-gnu/gcc-bin/14/g++
	# Using gcc-14 to avoid Internal Compiler Error.

	sed -i "0,/beast/s///;0,/process/s///" CMakeLists.txt 3rdpart/sast-link-cxx-sdk/CMakeLists.txt || die
	sed -i "/Boost::beast/d;/Boost::process/d" 3rdpart/sast-link-cxx-sdk/CMakeLists.txt src/CMakeLists.txt || die
	cmake_src_configure
}

src_install() {
	cmake_src_install
	newicon "${S}/ui/assets/image/icon/evento.png" ${PN}.png
	make_desktop_entry ${PN} "SAST Evento" "" "" "Categories=Internet;Office;"
}

pkg_postinst() {
	xdg_pkg_postinst
}
