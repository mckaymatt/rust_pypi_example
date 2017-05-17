set -ex

source `dirname $0`/utils.sh

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
    export RUSTRELEASE='stable'
    # This is for local testing. You can change the default to match your system.
else 
    echo "RUSTRELEASE is $RUSTRELEASE"
fi


if [[ $WHEELPLATFORM == *"manylinux"* ]]; then
    echo "Manylinx does not require Cross - WHEELPLATFORM=$WHEELPLATFORM"
elif [[ $RUSTCOMPILER == "RUSTUP" ]]; then
    rustup_install
elif [[ $RUSTCOMPILER == "CROSS" ]]; then
    # for now I don't think we actually need cross but we can leave this in.
    cross_install
else
    echo "RUSTCOMPILER is not set and this isn't a Manylinux wheel - exit 2"
    exit 2
fi
