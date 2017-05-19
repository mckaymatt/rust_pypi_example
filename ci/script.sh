# This script takes care of testing your crate
#!/bin/bash
set -ex

# load shared functions
source `dirname $0`/utils.sh

# This builds "manylinux" python packages in the manylinux docker container
# More on manylinuyx at https://github.com/pypa/manylinux
# and the pep https://www.python.org/dev/peps/pep-0513
manylinux_build_test_bundle() {
    # cache pip packages used in docker
    mkdir -p "$HOME/.manylinux_pip_cache"
    mkdir -p "$HOME/.manylinux_cargo_cache"
    mkdir -p "$HOME/.manylinux_rustup_cache"

    # WHEELPLATFORM is either "manylinux1_i686" or "manylinux1_x86_64"
    docker run --rm  -e "WHEELPLATFORM=${WHEELPLATFORM}" \
    -e TARGET="${TARGET}" \
    -e RUSTRELEASE="${RUSTRELEASE}" \
    -v ${HOME}/.manylinux_pip_cache:/root/.cache/pip \
    -v ${HOME}/.manylinux_cargo_cache:/root/.cargo \
    -v ${HOME}/.manylinux_rustup_cache:/root/.rustup \
    -v `pwd`:/io \
    "quay.io/pypa/${WHEELPLATFORM}" \
    /io/ci/manylinux_build_wheel.sh

}

# does not run in docker
pyenv_build_test_bundle() {
    rm -rf wheelhouse
    mkdir -p wheelhouse
    source $HOME/.cargo/env

    IFS="," # allows iterating over csv string
    for CURRENT_PYENV in $PYENV; do
        echo "CURRENT_PYENV is $CURRENT_PYENV"
        set +x
        source /tmp/.venv/${CURRENT_PYENV}/bin/activate
        set -x
        make clean
        pip install -q -r requirements_dev.txt
        python setup.py clean
        python setup.py build_ext
        if [ -z ${WHEELPLATFORM+x} ]; then
            python setup.py bdist_wheel
        else
            python setup.py bdist_wheel --plat-name="$WHEELPLATFORM"
        fi
        cp dist/*.whl wheelhouse
        python setup.py develop
        python setup.py test
        python setup.py check

        set +x
        deactivate
        set -x
    done
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
    manylinux_build_test_bundle
fi
