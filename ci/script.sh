# This script takes care of testing your crate

set -ex

# This builds "manylinux" python packages in the manylinux docker container
# More on manylinuyx at https://github.com/pypa/manylinux
# and the pep https://www.python.org/dev/peps/pep-0513
manylinux_linux() {
    # cache pip packages used in docker
    mkdir -p "$HOME/.manylinux_pip_cache"
    mkdir -p "$HOME/.manylinux_cargo_cache"
    mkdir -p "$HOME/.manylinux_rustup_cache"

    CACHES="-v $HOME/.manylinux_pip_cache:/root/.cache/pip \
           -v $HOME/.manylinux_cargo_cache:/root/.cargo \
           -v $HOME/.manylinux_rustup_cache:/root/.rustup " 

    # WHEELPLATFORM is either "manylinux1_i686" or "manylinux1_x86_64"
    docker run --rm -e TARGET="${TARGET}" -e RUSTRELEASE="${RUSTRELEASE}" $CACHES -v `pwd`:/io "quay.io/pypa/${WHEELPLATFORM}" /io/ci/manylinux_build_wheel.sh

}

# This is for OSX mainly. It gets python from Pyenv and uses Rustup for getting rustc. 
# it could also be used for testing on other nixes
pyenv_build_test_bundle() {
    # This uses cross and Pyenv
    curl https://sh.rustup.rs -sSf > /tmp/rustup.sh
    sh /tmp/rustup.sh -y
    source $HOME/.cargo/env
    rustup install "${RUSTRELEASE}-${TARGET}"
    rustup default "${RUSTRELEASE}-${TARGET}"
    rustup update

    pushd trust_pypi_example/rust/
    cargo build --target $TARGET --release
    # pushd trust_pypi_example/rust/
    # cross build --target $TARGET --release

    # disable tests
    if [ ! -z $DISABLE_TESTS ]; then
        echo "Rust Tests Disabled"
    else
        cargo test --target $TARGET --release
        # cross test --target $TARGET --release
    fi
    # uncomment if creating a bin
    # cross run --target $TARGET
    # cross run --target $TARGET --release

    # hack 
    # move target/$TARGET/release to target/release to make
    # it easier to locate for py dist. See trust_pypi_example.py
    if [ ! -d "target/${TARGET}/release" ]; then
        echo "Cannot find release dir at target/$TARGET/release"
        exit 2
    else
        pushd target
        mv release release.bak || true
        cp -r $TARGET/release release
        popd
    fi
    popd
    rm -rf wheelhouse
    mkdir -p wheelhouse
    source .venv/bin/activate
    pip install -q -r requirements_dev.txt
    python setup.py bdist_wheel  --plat-name="$WHEELPLATFORM"
    cp dist/*.whl wheelhouse
    pip install wheelhouse/*.whl
    py.test tests/
    


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


if [ -z ${RUSTRELEASE+x} ]; then
    if [ ! -z ${TRAVIS_BUILD_NUMBER+x} ]; then
        echo "RUSTRELEASE not set but it looks like this is running on Travis."
        exit 2
    fi
    echo "RUSTRELEASE is not set. Defaulting to stable"
    export RUSTRELEASE=stable
    # This is for local testing. You can change the default to match your system.
else 
    echo "RUSTRELEASE is $RUSTRELEASE"
fi


if [ "$TRAVIS_OS_NAME" == "osx" ]; then
    pyenv_build_test_bundle
else
    manylinux_linux
fi
