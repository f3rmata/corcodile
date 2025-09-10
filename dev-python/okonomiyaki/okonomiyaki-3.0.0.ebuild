# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..13} )

inherit distutils-r1 pypi

DESCRIPTION="
	Self-contained library to deal with metadata in Enthought-specific egg and runtime archives.
"
HOMEPAGE="
	https://github.com/enthought/okonomiyaki
	https://pypi.org/project/okonomiyaki/
"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"

distutils_enable_tests pytest

src_prepare() {
	sed -i -e '/^\[bdist_wheel\]/,/^$/d' setup.cfg || die

	sed -i -E \
		-e 's/^(include|exclude|recursive-include|recursive-exclude)/# \1/' \
		MANIFEST.in || die
	distutils-r1_src_prepare
}
