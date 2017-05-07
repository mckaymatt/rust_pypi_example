# This script takes care of building your crate and packaging it for release

# Since we are mostly concerned with building a wheel I don't even run this.

set -ex

main() {
    # move into rust project subdir
    cd trust_pypi_example/rust/

    local src=$(pwd) \
          stage=

    case $TRAVIS_OS_NAME in
        linux)
            stage=$(mktemp -d)
            ;;
        osx)
            stage=$(mktemp -d -t tmp)
            ;;
    esac

    test -f Cargo.lock || cargo generate-lockfile



    # # TODO Update this to build the artifacts that matter to you
    # cross rustc --bin hello --target $TARGET --release -- -C lto

    # # TODO Update this to package the right artifacts
    # cp target/$TARGET/release/hello $stage/

    # cd $stage
    # tar czf $src/$CRATE_NAME-$TRAVIS_TAG-$TARGET.tar.gz *
    # cd $src

    # rm -rf $stage
}

# main
