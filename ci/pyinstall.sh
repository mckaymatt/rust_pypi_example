set -ex

pyenv --version || true

# get most up to date pyenv but keep cache of Python versions
rm -rf ~/.pyenv ~/.venv
git clone https://github.com/yyuu/pyenv.git ~/.pyenv
mkdir -p ~/.cache/pyenv/versions
ln -s ~/.cache/pyenv/versions ~/.pyenv/versions
pyenv --version
pyenv install --skip-existing $PYENV
pyenv global $PYENV

pyenv rehash

python --version

pip install -U pip
pip install -U virtualenv
python -m virtualenv ~/.venv
ls -la ~/.venv
ls -la ~/.venv/bin/
. ~/.venv/bin/activate

pip install -U pip
pip install -r requirements_dev.txt