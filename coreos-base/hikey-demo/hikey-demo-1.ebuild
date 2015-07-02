# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

DESCRIPTION="Image for demo of CoreOS on the 96boards ARM64 HiKey"
HOMEPAGE="https://www.96boards.org/products/ce/hikey/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm64"
IUSE=""


my_others="
	sys-kernel/bootengine
"

DEPEND="
	sys-kernel/coreos-kernel
	virtual/linux-sources
	sys-apps/baselayout
	net-misc/openssh
	sys-block/parted
	app-editors/vim
	sys-apps/findutils
	sys-apps/which
	app-admin/sudo
	app-admin/toolbox
	app-arch/tar
	app-arch/unzip
	app-shells/bash
	net-misc/dhcpcd
	net-misc/ntp
	net-misc/rsync
	net-misc/wget
	sys-apps/coreutils
	sys-apps/dbus
	sys-apps/gawk
	sys-apps/grep
	sys-apps/iproute2
	sys-apps/less
	sys-apps/net-tools
	sys-apps/rootdev
	sys-apps/sed
	sys-apps/shadow
	sys-apps/systemd
	sys-apps/util-linux
	sys-fs/btrfs-progs
	sys-fs/e2fsprogs
	sys-fs/mdadm
	sys-libs/glibc
	sys-libs/timezone-data
	sys-process/lsof
	sys-process/procps
	virtual/udev
	net-misc/iputils
	coreos-base/coreos-init
	app-emulation/docker
	dev-util/strace
"

RDEPEND="${DEPEND}"
