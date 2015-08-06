# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

ETYPE=sources
K_SECURITY_UNSUPPORTED=1
inherit kernel-2
detect_version
detect_arch

inherit git-2 versionator
EGIT_REPO_URI=https://github.com/96boards/linux.git
EGIT_PROJECT="hikey-linux.git"
EGIT_BRANCH="hikey"
#SRC_URI="https://github.com/96boards/linux/tarball/hikey"

DESCRIPTION="96 HiKey kernel sources"
HOMEPAGE="https://github.com/96boards/linux"

KEYWORDS="arm64"
