#!/usr/bin/env python
# -*- coding: utf-8 -*-

from setuptools import setup, Distribution


# Wheel thinks we are building a pure python wheel since we use cross for compilation 
# instead of wheel
# http://stackoverflow.com/questions/35112511/pip-setup-py-bdist-wheel-no-longer-builds-forced-non-pure-wheels
# Tested with wheel v0.29.0
# may fail with different version of wheel
class BinaryDistribution(Distribution):
    """Distribution which always forces a binary package with platform name"""
    def has_ext_modules(foo):
        return True


with open('README.rst') as readme_file:
    readme = readme_file.read()

with open('HISTORY.rst') as history_file:
    history = history_file.read()

requirements = [
    'cffi>=1.0.0',
    'Click>=6.0',
    # TODO: put package requirements here
]

test_requirements = [
    # TODO: put package test requirements here
]

setup(
    distclass=BinaryDistribution,
    name='trust_pypi_example',
    version='0.1.0',
    description="Python Boilerplate contains all the boilerplate you need to create a Python wheel with Rust.",
    long_description=readme + '\n\n' + history,
    author="Matt McKay",
    author_email='mckaymatt@gmail.com',
    url='https://github.com/mckaymatt/trust_pypi_example',
    packages=[
        'trust_pypi_example',
    ],
    package_dir={'trust_pypi_example':
                 'trust_pypi_example'},
    entry_points={
        'console_scripts': [
            'trust_pypi_example=trust_pypi_example.cli:main'
        ]
    },
    include_package_data=True,
    install_requires=requirements,
    license="Apache Software License 2.0",
    zip_safe=False,
    keywords='trust_pypi_example',
    classifiers=[
        'Development Status :: 2 - Pre-Alpha',
        'Intended Audience :: Developers',
        'License :: OSI Approved :: Apache Software License',
        'Natural Language :: English',
        "Programming Language :: Python :: 2",
        'Programming Language :: Python :: 2.6',
        'Programming Language :: Python :: 2.7',
        'Programming Language :: Python :: 3',
        'Programming Language :: Python :: 3.3',
        'Programming Language :: Python :: 3.4',
        'Programming Language :: Python :: 3.5',
    ],
    test_suite='tests',
    tests_require=test_requirements,
)
