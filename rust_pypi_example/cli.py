# -*- coding: utf-8 -*-

import click
from .rust_pypi_example import rust_lib

CONTEXT_SETTINGS = dict(help_option_names=['-h', '--help'])


@click.command(context_settings=CONTEXT_SETTINGS)
@click.argument('number', nargs=1, type=int, required=False)
def main(number=None):
    """Console script for rust_pypi_example
       The console script takes a singe argument, "NUMBER",
       which must be an integer greater than 2. The script calls
       out to a library written in Rust to compute whether the
       intger is a prime number.
       Example:
           rust_pypi_example 13
    """
    if number and number > 2:
        click.echo(True if rust_lib.is_prime(number) else False)
    else:
        click.echo("Please supply an integer argument greater than 2. The "
                   "console script will tell you if it is a prime number")


if __name__ == "__main__":
    main()
