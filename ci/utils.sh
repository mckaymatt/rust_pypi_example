cross_install() {
    # This is unused for now
    local target=
    if [ $TRAVIS_OS_NAME = linux ]; then
        target=x86_64-unknown-linux-musl
        sort=sort
    else
        target=x86_64-apple-darwin
        sort=gsort  # for `sort --sort-version`, from brew's coreutils.
    fi

    # This fetches latest stable release
    # local tag=$(git ls-remote --tags --refs --exit-code https://github.com/japaric/cross \
    #                    | cut -d/ -f3 \
    #                    | grep -E '^v[0.1.0-9.]+$' \
    #                    | $sort --version-sort \
    #                    | tail -n1)
    curl -LSfs https://japaric.github.io/trust/install.sh | \
        sh -s -- \
           --force \
           --git japaric/cross \
           --tag 'v0.1.10' \
           --target $target
}

rustup_install() {
    curl https://sh.rustup.rs -sSf > /tmp/rustup.sh
    sh /tmp/rustup.sh -y
    source $HOME/.cargo/env
    rustup install "${RUSTRELEASE}-${TARGET}"
    rustup default "${RUSTRELEASE}-${TARGET}"
    rustup update
}



