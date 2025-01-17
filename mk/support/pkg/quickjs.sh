version=2021-03-27

src_url=https://bellard.org/quickjs/quickjs-${version}.tar.xz
src_url_sha1=95836721cf3931a0043461db6c710415f05ed2cf

pkg_configure () {
    ( cd "$build_dir" && sed "s!^prefix=/usr/local\$!prefix=$(niceabspath "$install_dir")!" < Makefile > Makefile.tmp && mv Makefile.tmp Makefile )
}

pkg_link-flags () {
    local lib="$install_dir/lib/quickjs/libquickjs.a"
    if [[ ! -e "$lib" ]]; then
        echo "quickjs.sh: error: static library was not built: $lib" >&2
        exit 1
    fi
    echo "$lib"
}

pkg_install-include () {
    test -e "$install_dir/include" && rm -rf "$install_dir/include"
    mkdir -p "$install_dir/include/quickjs"
    cp "$src_dir"/quickjs.h "$install_dir/include/quickjs"
}

pkg_install () {
    if ! fetched; then
        error "cannot install package, it has not been fetched"
    fi
    pkg_copy_src_to_build
    pkg_configure ${configure_flags:-}
    # The pkg.sh pkg_install would work on newer systems (invoking
    # "pkg_make install").  But instead, we (a) avoid building quickjs
    # executables, and (b) we avoid linking problems that occur on
    # older platforms with those executables.
    pkg_make libquickjs.a
    mkdir -p "$install_dir/lib/quickjs"
    install -m644 "$build_dir/libquickjs.a" "$install_dir/lib/quickjs/libquickjs.a"
}
