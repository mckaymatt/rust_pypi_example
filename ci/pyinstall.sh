set -ex
rm -rf ~/.pyenv
git clone https://github.com/yyuu/pyenv.git ~/.pyenv
mkdir -p ~/.cache/pyenv/versions
ln -s ~/.cache/pyenv/versions ~/.pyenv/versions
export PATH="$HOME/.pyenv/shims:$HOME/.pyenv/bin:$PATH"
pyenv install --skip-existing $PYENV
pyenv global $PYENV
pyenv --version

pyenv rehash

python --version
pip --version
pip install -U pip
pip install -U virtualenv
python -m virtualenv ~/.venv
