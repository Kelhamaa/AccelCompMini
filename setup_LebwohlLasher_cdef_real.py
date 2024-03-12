from setuptools import setup
from Cython.Build import cythonize

setup(
    name="LebwohlLasher_cdef_real",
    ext_modules=cythonize("LebwohlLasher_cdef_real.pyx"),
    )  