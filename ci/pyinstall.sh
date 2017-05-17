set -ex

du -shx $HOME/.cache/pip $HOME/.cache/pyenv $HOME/.cargo $HOME/.rustup \
        $HOME/.manylinux_pip_cache $HOME/.manylinux_rustup_cache \
        $HOME/.manylinux_cargo_cache || true


function pyenv_install() {
    # Set up pyinstall and the virtualenv
    PATH="$HOME/.pyenv/shims:$HOME/.pyenv/bin:$PATH"
    pyenv --version || true
    if [ -d "$HOME/.pyenv/.git" ]; then
        # for local testing
        pushd "$HOME/.pyenv"
        git pull
        popd
    else
        rm -rf ~/.pyenv
        git clone https://github.com/yyuu/pyenv.git $HOME/.pyenv
        mkdir -p ~/.cache/pyenv/versions
        ln -s ~/.cache/pyenv/versions ~/.pyenv/versions
    fi

    # make venvs for each version we want to test
    rm -rf /tmp/.venv /tmp/pyenv_versions
    
    IFS="," # allows iterating over csv string
    for CURRENT_PYENV in $PYENV; do
        echo "$CURRENT_PYENV" >> /tmp/pyenv_versions
    done
    # try and speed this up by installing in parallel
    cat  /tmp/pyenv_versions | xargs -L 1 -P 10 pyenv install --skip-existing 

    for CURRENT_PYENV in $PYENV; do
        pyenv global $CURRENT_PYENV

        pyenv rehash
        python --version
        pip install -q -U pip 
        pip install -q -U virtualenv
        python -m venv "/tmp/.venv/${CURRENT_PYENV}" || python -m virtualenv "/tmp/.venv/${CURRENT_PYENV}"
        set +x
        source /tmp/.venv/${CURRENT_PYENV}/bin/activate
        pip install -q -U pip 
        deactivate
        set -x

    done
}


if [[ $WHEELPLATFORM == *"manylinux"* ]]; then
    echo "skipping pyenv install" 
else
    if [ -z ${PYENV+x} ]; then 
        # This is for local testing. You can change the default to match your system.
        export PYENV='3.6.1'
        echo "PYENV is not set. Defaulting to python $PYENV."
        if [ ! -z ${TRAVIS_BUILD_NUMBER+x} ]; then
            # should not see TRAVIS_BUILD_NUMBER if this is local testing.
            echo "TARGET is not set but TRAVIS_BUILD_NUMBER is. Exiting with error"
            exit 2
        fi
    else
        echo "PYENV is $PYENV"
    fi

    pyenv_install 
fi
