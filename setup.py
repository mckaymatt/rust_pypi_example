#!/usr/bin/env python
# -*- coding: utf-8 -*-

from setuptools import setup

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
    name='trust_pypi_example',
    version='0.1.0',
    description="produced by cookiecutter",
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
    tests_require=test_requirements
)