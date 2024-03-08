from setuptools import setup
from Cython.Build import cythonize

setup(
    name="LebwohlLasher_cdef_Nump_Cyth",
    ext_modules=cythonize("LebwohlLasher_Nump_Cyth.pyx"),
    )  