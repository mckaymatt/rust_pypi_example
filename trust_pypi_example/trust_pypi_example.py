# -*- coding: utf-8 -*-
import os.path
import sys
from cffi import FFI

# See https://github.com/SimonSapin/hello-pyrust

ffi = FFI()
ffi.cdef(open(os.path.join(
    # FIXME: path is hard-coded
    os.path.dirname(__file__), 'rust', 'src',
    'trust_pypi_example.h',
)).read())

if sys.platform == 'win32':
    DYNAMIC_LIB_FORMAT = '%s.dll'
elif sys.platform == 'darwin':
    DYNAMIC_LIB_FORMAT = 'lib%s.dylib'
# FIXME: Does this need to check for other values of `sys.platform`?
else:
    DYNAMIC_LIB_FORMAT = 'lib%s.so'

rust_lib = ffi.dlopen(os.path.join(
    # FIXME: path is hard-coded
    # If the crate is built without the "--release" flag
    # the path will be 'rust/target/debug' and this will
    # cause OSError
    os.path.dirname(__file__), 'rust', 'target', 'release',
    DYNAMIC_LIB_FORMAT % 'trust_pypi_example'
))


def main():
    assert rust_lib.is_prime(13) == 1
    assert rust_lib.is_prime(12) == 0

if __name__ == '__main__':
    main()
