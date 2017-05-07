#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
test_trust_pypi_example
----------------------------------

Tests for `trust_pypi_example` module.
"""

import pytest

from click.testing import CliRunner

from trust_pypi_example import trust_pypi_example
from trust_pypi_example import cli


@pytest.fixture
def response():
    """Sample pytest fixture.
    See more at: http://doc.pytest.org/en/latest/fixture.html
    """
    # import requests
    # return requests.get('https://github.com/audreyr/cookiecutter-pypackage')


def test_content(response):
    """Sample pytest test function with the pytest fixture as an argument.
    """
    # from bs4 import BeautifulSoup
    # assert 'GitHub' in BeautifulSoup(response.content).title.string


def test_trust_pypi_example():
    assert trust_pypi_example.rust_lib.is_prime(12) is 0
    assert trust_pypi_example.rust_lib.is_prime(13) is 1


def test_command_line_interface():
    runner = CliRunner()
    result = runner.invoke(cli.main)
    assert result.exit_code == 0
    assert 'Please supply an integer argument ' in result.output
    help_result = runner.invoke(cli.main, ['--help'])
    assert help_result.exit_code == 0
    print(help_result.output)
    assert '--help  Show this message and exit.' in help_result.output
    non_prime_result = runner.invoke(cli.main, ['12'])
    assert non_prime_result.output.strip() == "False"
    prime_result = runner.invoke(cli.main, ['13'])
    assert prime_result.output.strip() == "True"
