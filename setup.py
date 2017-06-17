#!/usr/bin/env python
# -*- coding: utf-8 -*-

from setuptools import setup, Distribution
try:
    from setuptools_rust import RustExtension, Binding
except ImportError:
    import subprocess
    print("\nsetuptools_rust is required before install - https://pypi.python.org/pypi/setuptools-rust")
    print("attempting to install with pip...")
    print(subprocess.check_output(["pip", "install", "setuptools_rust"]))
    from setuptools_rust import RustExtension

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
    'pytest>=2.9.2',
    'pytest-runner>=2.0'
]

setup(
    name='rust_pypi_example',
    version='0.1.0',
    description="Python Boilerplate contains all the boilerplate you need to create a Python wheel with Rust.",
    long_description=readme + '\n\n' + history,
    author="Matt McKay",
    author_email='mckaymatt@gmail.com',
    url='https://github.com/mckaymatt/rust_pypi_example',
    packages=[
        'rust_pypi_example',
    ],
    package_dir={'rust_pypi_example':
                 'rust_pypi_example'},
    entry_points={
        'console_scripts': [
            'rust_pypi_example=rust_pypi_example.cli:main'
        ]
    },
    include_package_data=True,
    install_requires=requirements,
    license="Apache Software License 2.0",
    zip_safe=False,
    rust_extensions=[
        RustExtension('rust_pypi_example', 'rust_pypi_example/rust/Cargo.toml',
                       debug=False, binding=Binding.NoBinding)],
    keywords='rust_pypi_example',
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
    setup_requires=['setuptools_rust',
    'pytest-runner>=2.0',
    ]
)
