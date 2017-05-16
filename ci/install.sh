set -ex

main() {
    if [[ $WHEELPLATFORM == *"manylinux"* ]]; then
        echo "Manylinx does not require Cross - WHEELPLATFORM=$WHEELPLATFORM"
        return
    fi
    if [ ! -z ${SKIPCROSS+x} ]; then 
        # This is for local testing. It skips the install.
        echo "SKIPCROSS is set."
        return
    fi
    local target=
    if [ $TRAVIS_OS_NAME = linux ]; then
        target=x86_64-unknown-linux-musl
        # target=x86_64-unknown-linux-gnu
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


# Skipping this for now. 
# main
