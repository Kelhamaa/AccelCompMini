from setuptools import setup
from Cython.Build import cythonize

setup(
    name="LebwohlLasher_cdef_pyx",
    ext_modules=cythonize("LebwohlLasher_cdef.pyx"),
    )  