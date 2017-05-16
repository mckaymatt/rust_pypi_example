set -ex
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

pyenv --version
pyenv install --skip-existing $PYENV
pyenv global $PYENV

pyenv rehash

python --version
rm -rf .venv
pip install -U pip || true
pip install -U virtualenv || true
python -m venv .venv || python -m virtualenv .venv
source .venv/bin/activate
pip install -q -U pip 
pip install -q -r requirements_dev.txt 