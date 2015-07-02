# Copyright (c) 2015 CoreOS, Inc.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_PROJECT="coreos/rkt"
CROS_WORKON_LOCALNAME="rkt"
CROS_WORKON_REPO="git://github.com"
COREOS_GO_PACKAGE="github.com/coreos/rkt"
inherit cros-workon systemd coreos-go

if [[ "${PV}" == 9999 ]]; then
    KEYWORDS="~amd64 ~arm64"
else
    CROS_WORKON_COMMIT="40ced98c320c056e343fe9c3eaeb90a4ff248936" # v0.5.5
    KEYWORDS="amd64 arm64"
fi

# Must be in sync with stage1/rootfs/usr_from_coreos/cache.sh
IMG_RELEASE="444.5.0"
IMG_URL="http://stable.release.core-os.net/amd64-usr/${IMG_RELEASE}/coreos_production_pxe_image.cpio.gz"
#IMG_URL="http://stable.release.core-os.net/${ARCH}-usr/${IMG_RELEASE}/	coreos_production_pxe_image.cpio.gz"
IMAGE_FILE="pxe-${IMG_RELEASE}.img"

DESCRIPTION="App Container runtime"
HOMEPAGE="https://github.com/coreos/rkt"
SRC_URI="${IMG_URL} -> ${IMAGE_FILE}"

LICENSE="Apache-2.0"
SLOT="0"
IUSE=""

DEPEND="app-arch/cpio
	sys-fs/squashfs-tools"
RDEPEND="!app-emulation/rocket"

src_unpack() {
	debug-print-function ${PN}-${FUNCNAME} "$@"

	local cache="${S}/stage1/rootfs/usr_from_coreos/cache"

	cros-workon_src_unpack

	mkdir -p "${cache}" || die
	cp "${DISTDIR}/${IMAGE_FILE}" "${cache}/pxe.img" || die
}

src_compile() {
	debug-print-function ${PN}-${FUNCNAME} "$@"

	ebegin "Building rkt (stage0)"

	#RKT_STAGE1_USR_FROM="coreos"
	#RKT_STAGE1_IMAGE="/usr/share/rkt/stage1.aci"
	#GO_LDFLAGS+="-X main.defaultStage1Image '${RKT_STAGE1_IMAGE}'"

	go_build "${COREOS_GO_PACKAGE}/rkt"

	eend ${?} "Building rkt (stage0) failed" || die

	ebegin "Building rkt network plugins"
	einfo "FIXME: TODO"
	true
	eend ${?} "Building rkt network plugins failed" || die
}

src_install() {
	debug-print-function ${PN}-${FUNCNAME} "$@"

	local prefix="/usr/share/rkt"

	dobin "${GOBIN}/rkt"

	insinto ${prefix}
	doins "${DISTDIR}/${IMAGE_FILE}"
	dosym "${IMAGE_FILE}" "${prefix}/stage1.aci"

	systemd_dounit "${FILESDIR}"/${PN}-gc.service
	systemd_dounit "${FILESDIR}"/${PN}-gc.timer
}
