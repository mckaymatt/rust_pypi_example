# -*- coding: utf-8 -*-
import os.path
import sys
from cffi import FFI

# See https://github.com/SimonSapin/hello-pyrust

ffi = FFI()
ffi.cdef(open(os.path.join(
    # FIXME: path is hard-coded
    os.path.dirname(__file__), 'rust', 'src',
    'rust_pypi_example.h',
)).read())

if sys.platform == 'win32':
    DYNAMIC_LIB_FORMAT = '%s.dll'
elif sys.platform == 'darwin':
    DYNAMIC_LIB_FORMAT = 'lib%s.dylib'
elif "linux" in sys.platform:
    DYNAMIC_LIB_FORMAT = 'lib%s.so'
else:
    raise NotImplementedError('No implementation for "{}".'
                              ' Supported platforms are '
                              '"win32", "darwin", and "linux"'
                              ''.format(sys.platform))

DLPATH = os.path.join(
    # If the crate is built without the "--release" flag
    # the path will be 'rust/target/debug' and this will
    # cause OSError
    os.path.dirname(__file__), 'rust', 'target', 'release',
    DYNAMIC_LIB_FORMAT % 'rust_pypi_example'
    )

rust_lib = ffi.dlopen(DLPATH)


def main():
    assert rust_lib.is_prime(13) == 1
    assert rust_lib.is_prime(12) == 0


if __name__ == '__main__':
    main()
