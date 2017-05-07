# this packages the Rust lib in with you Python package and runs tests
set -ex

python --version
source ~/.venv/bin/activate
python --version

pip install -U pip
pip install -r requirements_dev.txt
make test 
make lint

python setup.py bdist_wheel
ls -la dist