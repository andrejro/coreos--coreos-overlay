# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header:  $

EAPI=5

inherit eutils toolchain-funcs

EGIT_REPO_URI="git://github.com/golang/go.git"
inherit git-r3
KEYWORDS="-* ~amd64 arm64"

DESCRIPTION="A concurrent garbage collected and typesafe programming language"
HOMEPAGE="http://www.golang.org"

LICENSE="BSD"
SLOT="0"

IUSE="cros_host +arm64-extras"

DEPEND="cros_host? ( dev-lang/go-bootstrap )"

# FIXME: check this!!!
# The tools in /usr/lib/go should not cause the multilib-strict check to fail.
QA_MULTILIB_PATHS="${EROOT}usr/lib/go/pkg/tool/.*/.*"

# FIXME: these don't work!!!
# The go language uses *.a files which are _NOT_ libraries and should not be
# stripped.
STRIP_MASK+=" ${EROOT}usr/lib/go/pkg/linux_*/*.a"
STRIP_MASK+=" ${EROOT}usr/lib/go/pkg/linux_*/*/*.a"
STRIP_MASK+=" ${EROOT}usr/lib/go/pkg/linux_*/*/*/*.a"

my_header="${CATEGORY}/${PN}"

go_arch() {
	echo ${ARCH}
}

build_arch()
{
    case "$CBUILD" in
        aarch64*)   echo arm64;;
        x86_64*)    echo amd64;;
    esac
}

same_arch()
{
	[[ "${ARCH}" = "$(build_arch)" ]]
}

src_compile()
{
	cd src

	export GOOS="linux"
	export GOROOT_BOOTSTRAP="/usr/lib/go1.4"
	export GOROOT_FINAL="${EPREFIX}"/usr/lib/go
	export GOROOT="$(pwd)"
	export GOBIN=${GOROOT}/bin

	debug-print "${my_header}: EROOT=${EROOT}"
	debug-print "${my_header}: EPREFIX=${EPREFIX}"

	debug-print "${my_header}: GOROOT=${GOROOT}"
	debug-print "${my_header}: GOROOT_FINAL=${GOROOT_FINAL}"
	debug-print "${my_header}: CC_FOR_TARGET=${CC_FOR_TARGET}"

	if use cros_host && use arm64-extras; then
		export GOARCH="arm64"
		export CC_FOR_TARGET="aarch64-cros-linux-gnu-gcc"
		ebegin "Building for GOARCH=${GOARCH}..."
		./make.bash --no-clean --no-test
		eend $? "Build for GOARCH=${GOARCH} failed." || die
	fi

	# Build the host last to get the correct settings in the go environment.
	export GOARCH=$(go_arch)
	export CC_FOR_TARGET=$(tc-getCC)
	ebegin "Building for GOARCH=${GOARCH}..."
	./make.bash --no-clean --no-test
	eend $? "Build for GOARCH=${GOARCH} failed." || die
}

src_test()
{
	$(same_arch) || return;

	cd src
	PATH="${GOBIN}:${PATH}" \
		./run.bash --no-rebuild --banner || die "tests failed."
}

src_install()
{
	if $(same_arch); then
		dobin ${GOBIN}/go \
		${GOBIN}/gofmt
	else
		dobin ${GOBIN}/linux_$(go_arch)/go \
			${GOBIN}/linux_$(go_arch)/gofmt
	fi

	dodoc AUTHORS CONTRIBUTORS PATENTS README.md

	dodir /usr/lib/go
	insinto /usr/lib/go
	doins -r lib src

	dodir /usr/lib/go/pkg
	insinto /usr/lib/go/pkg
	doins -r pkg/include \
		pkg/linux_$(go_arch)

	dodir /usr/lib/go/pkg/tool
	insinto /usr/lib/go/pkg/tool
	doins -r pkg/tool/linux_$(go_arch)
	fperms -R +x /usr/lib/go/pkg/tool

	if use cros_host && use arm64-extras; then
		insinto /usr/lib/go/pkg
		doins -r pkg/linux_arm64

		insinto /usr/lib/go/pkg/tool
		doins -r pkg/tool/linux_arm64
		fperms -R +x pkg/tool/linux_arm64
	fi
}

FIXME_do_we_still_need_this__pkg_postinst()
{
	# If the go tool sees a package file timestamped older than a dependancy it
	# will rebuild that file.  So, in order to stop go from rebuilding lots of
	# packages for every build we need to fix the timestamps.  The compiler and
	# linker are also checked - so we need to fix them too.

	find ${EROOT}usr/lib/go -type f -exec touch -r ${EROOT}usr/bin/go {} \;
}
