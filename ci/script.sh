# This script takes care of testing your crate

set -ex

main() {
    # move into rust project subdir
    pushd trust_pypi_example/rust/
    cross build --target $TARGET
    cross build --target $TARGET --release

    # disable tests
    if [ ! -z $DISABLE_TESTS ]; then
        echo "Rust Tests Disabled"
    else
        cross test --target $TARGET
        cross test --target $TARGET --release
    fi
    # uncomment if creating a bin
    # cross run --target $TARGET
    # cross run --target $TARGET --release

    # hack 
    # move target/$TARGET/release to target/release to make
    # it easier to locate for py dist. See trust_pypi_example.py
    if [ ! -d "target/$TARGET/release" ]; then
        echo "Cannot find release dir at target/$TARGET/release"
        exit 2
    else
        pushd target
        mv release release.bak || true
        ln -s $TARGET/release release
        popd
    fi
    popd
}

pymain() {
    source .venv/bin/activate
    python setup.py bdist_wheel

    make test
    make lint
    make coverage
    make docs
}


if [ -z ${TARGET+x} ]; then
    if [ ! -z ${TRAVIS_BUILD_NUMBER+x} ]; then
        echo "Target not set but it looks like this is running on Travis."
        exit 2
    fi
    echo "TARGET is not set. Defaulting to x86_64-unknown-linux-gnu"
    export TARGET='x86_64-unknown-linux-gnu'
    # This is for local testing. You can change the default to match your system.

else 
    echo "TARGET is $TARGET"
fi




main
pymain