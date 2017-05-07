# this packages the Rust lib in with you Python package and runs tests
set -ex
printenv ||true
export PATH="$HOME/.pyenv/shims:$HOME/.pyenv/bin:$PATH"

source ~/.venv/bin/activate
pip install -U pip
pip install -r requirements-test.txt
make test 
make lint
# python --version
# pip --version
# pip install virtualenv
# python -m virtualenv ~/.venv
# source ~/.venv/bin/activate
# pip install coveralls
# pip install .[credssp]
# pip install .[kerberos]
# pip install -r requirements-test.txt