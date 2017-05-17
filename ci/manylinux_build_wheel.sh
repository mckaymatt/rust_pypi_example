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

source `dirname $0`/utils.sh

export USER='root'
chown -fR root:root /root/.cache/pip /root/.cargo /root/.rustup

function manylinux_build_test_and_bundle() {
    rustup_install

    cd /io
    rm -rf /io/wheelhouse
    mkdir -p wheelhouse
    source $HOME/.cargo/env

    # remove unnneded versions
    rm -rf /opt/python/cp26*
    # rm -rf /opt/python/cp27*  # uncludes m and mu
    # rm -rf /opt/python/cp33*
    # rm -rf /opt/python/cp34*
    # rm -rf /opt/python/cp35*
    # rm -rf /opt/python/cp36*


    # Skips 2.6 {cp27*,cp3*}
    for PYBIN in /opt/python/*/bin/; do
        "${PYBIN}/pip" install -U pip virtualenv
        "${PYBIN}/virtualenv" /tmp/$PYBIN
        set +x
        source "/tmp${PYBIN}/bin/activate"
        set -x
        pip install -q -U pip
        pip install -q -r requirements_dev.txt
        python setup.py clean
        make clean
        python setup.py build_ext
        if [ -z ${WHEELPLATFORM+x} ]; then
            python setup.py bdist_wheel
        else
            python setup.py bdist_wheel  --plat-name="$WHEELPLATFORM"
        fi
        cp dist/*.whl wheelhouse || true
        python setup.py test # should work with py.test
        python setup.py check
        python setup.py develop
        set +x
        deactivate
        set -x
    done
}


# rust_build
manylinux_build_test_and_bundle
RETURNOWNERSHIP
