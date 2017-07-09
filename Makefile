.PHONY: clean clean-test clean-pyc clean-build clean-venv docs help install dist test test-all 
.DEFAULT_GOAL := help
define BROWSER_PYSCRIPT
import os, webbrowser, sys
if os.environ.get('TRAVIS_BUILD_NUMBER'):
	exit(0)
try:
	from urllib import pathname2url
except:
	from urllib.request import pathname2url

webbrowser.open("file://" + pathname2url(os.path.abspath(sys.argv[1])))
endef
export BROWSER_PYSCRIPT

define PRINT_HELP_PYSCRIPT
import re, sys

for line in sys.stdin:
	match = re.match(r'^([a-zA-Z_-]+):.*?## (.*)$$', line)
	if match:
		target, help = match.groups()
		print("%-20s %s" % (target, help))
endef
export PRINT_HELP_PYSCRIPT
BROWSER := python -c "$$BROWSER_PYSCRIPT"

help:
	@python -c "$$PRINT_HELP_PYSCRIPT" < $(MAKEFILE_LIST)

clean: clean-build clean-pyc clean-test clean-venv ## remove all build, test, coverage, Python artifacts and virtualenv


clean-build: ## remove build artifacts
	rm -fr build/
	rm -fr dist/
	rm -fr rust_pypi_example/rust/target
	rm -fr .eggs/
	rm -f *.so *.dylib *.dll 
	find . -name '*.egg-info' -exec rm -fr {} +
	find . -name '*.egg' -exec rm -fr {} +

clean-pyc: ## remove Python file artifacts
	find . -name '*.pyc' -exec rm -f {} +
	find . -name '*.pyo' -exec rm -f {} +
	find . -name '*~' -exec rm -f {} +
	find . -name '__pycache__' -exec rm -fr {} +

clean-test: ## remove test and coverage artifacts
	rm -fr .tox/
	rm -f .coverage
	rm -fr htmlcov/

clean-venv:
	rm -rf venv

lint: venv ## check style with flake8
	venv/bin/python -m flake8 rust_pypi_example tests

test: venv ## This will use py.test because of pytest-runner
	venv/bin/python setup.py build_ext
	venv/bin/python setup.py check
	venv/bin/python setup.py test

venv:  ## set up a virtualenv that will by python and install dependencies
	python -m virtualenv venv || python -m venv venv
	venv/bin/python -m pip install -r requirements_dev.txt


test-all: venv ## run tests on every Python version with tox
	venv/bin/tox

coverage: venv ## check code coverage quickly with the default Python
	venv/bin/python -m coverage run --source rust_pypi_example -m pytest
	
		venv/bin/python -m coverage report -m
		venv/bin/python -m coverage html
		$(BROWSER) htmlcov/index.html

docs: venv ## generate Sphinx HTML documentation, including API docs
	rm -f docs/rust_pypi_example.rst
	rm -f docs/modules.rst
	venv/bin/python -m sphinx-apidoc -o docs/ rust_pypi_example
	$(MAKE) -C docs clean
	$(MAKE) -C docs html
	$(BROWSER) docs/_build/html/index.html

servedocs: venv docs ## compile the docs watching for changes
	venv/bin/python -m watchmedo shell-command -p '*.rst' -c '$(MAKE) -C docs html' -R -D .

dist: venv clean ## builds source and wheel package
	venv/bin/python setup.py sdist
	venv/bin/python setup.py build_ext
	venv/bin/python setup.py bdist_wheel
	ls -l dist

install: venv clean ## install the package to the active Python's site-packages
	venv/bin/python setup.py build_ext
	venv/bin/python setup.py install


local-test: clean test coverage dist install 
