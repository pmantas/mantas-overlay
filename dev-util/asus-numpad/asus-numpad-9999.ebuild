EAPI=8
inherit git-r3 udev

DESCRIPTION="ASUS NumberPad userspace driver (iamkroot/asus-numpad) - live git"
HOMEPAGE="https://github.com/iamkroot/asus-numpad"
EGIT_REPO_URI="https://github.com/iamkroot/asus-numpad.git"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="
    dev-vcs/git
    dev-libs/libevdev
    virtual/udev
    || ( dev-lang/rust dev-lang/rust-bin )
"
RDEPEND="${DEPEND}"

S="${WORKDIR}/asus-numpad-9999"

src_prepare() {
    sed -e '/^strip/s/true/false/' -i Cargo.toml || die # bug 866133
    default
}

src_compile() {
    cd "${S}" || die
    export CARGO_HOME="${T}/.cargo"
    cargo build --release --locked --target-dir "${T}/target"
}

src_install() {
    # binary
    dobin "${T}/target/release/asus-numpad"

    # udev rules
    insinto /lib/udev/rules.d
    newins "${FILESDIR}/10-uinput.rules" 10-uinput.rules

    # init script
    insinto /etc/init.d
    newinitd "${FILESDIR}/asus-numpad.initd" asus-numpad
}

pkg_postinst() {
    udev_reload
}

pkg_postrm() {
    udev_reload
}
