#!/bin/bash
# Runs in the manylinx Docker container
# https://github.com/pypa/manylinux
# https://www.python.org/dev/peps/pep-0513

set -e -x

function RETURNOWNERSHIP {
    # We need to change perms back to user in the end since we run as root in the manylinux container 
    chown -Rf --reference=/io/setup.py /io /root/.cache/pip /root/.cargo /root/.rustup 
}
trap RETURNOWNERSHIP EXIT

export USER='root' 
chown -fR root:root /root/.cache/pip /root/.cargo /root/.rustup 

function rust_build() {
    # We build our Rust lib here so it will be compatible with old versions of common shared libs
    
    # install rustup inside the manylinux container
    curl https://sh.rustup.rs -sSf > /tmp/rustup.sh
    sh /tmp/rustup.sh -y
    source $HOME/.cargo/env
    rustup install "nightly-$TARGET"
    rustup default "nightly-$TARGET"
    rustup update

    cd /io/trust_pypi_example/rust/
    cargo build --target $TARGET --release

    # disable tests
    if [ ! -z $DISABLE_TESTS ]; then
        echo "Rust Tests Disabled"
    else 
        cargo test --target $TARGET --release
    fi
    # uncomment if creating a bin
    # cargo run --target $TARGET
    # cargo run --target $TARGET --release

    if [ ! -d "target/$TARGET/release" ]; then
        echo "Cannot find release dir at target/$TARGET/release"
        exit 2
    else
        pushd target
        mv release release.bak || true
        cp -r $TARGET/release release
        popd
    fi

}

function manylinux_test_and_bundle() {
    cd /io
    rm -rf /io/wheelhouse

    # Skips 2.6
    for PYBIN in /opt/python/{cp27*,cp3*}/bin/; do
        "${PYBIN}/pip" install -U pip virtualenv
        "${PYBIN}/virtualenv" /tmp/$PYBIN
        source "/tmp${PYBIN}/bin/activate"
        pip install -q -U pip 
        pip install -q -r /io/requirements_dev.txt
        pip wheel /io/ -w /io/wheelhouse/
        deactivate
    done

    # Bundle external shared libraries into the wheels
    # for whl in /io/wheelhouse/*.whl; do
    #     auditwheel show "$whl" 
    #     auditwheel repair "$whl" -w /io/wheelhouse/
    # done

    # Install packages and test
    for PYBIN in /opt/python/{cp27*,cp3*}/bin/; do
        source "/tmp${PYBIN}/bin/activate"
        "${PYBIN}/pip" install trust_pypi_example --no-index -f /io/wheelhouse
        py.test /io/tests/
        
        deactivate
    done
}


rust_build
manylinux_test_and_bundle
RETURNOWNERSHIP
