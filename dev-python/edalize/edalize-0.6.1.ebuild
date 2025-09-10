# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..13} )

inherit distutils-r1 pypi

DESCRIPTION="
	Library for interfacing EDA tools such as simulators, linters or synthesis tools, using a common interface.
"
HOMEPAGE="
	https://github.com/olofk/edalize/
	https://pypi.org/project/edalize/
"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~amd64"

distutils_enable_tests pytest
