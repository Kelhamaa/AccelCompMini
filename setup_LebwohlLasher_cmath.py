from setuptools import setup
from Cython.Build import cythonize

setup(
    name="LebwohlLasher_cmath",
    ext_modules=cythonize("LebwohlLasher_cmath.pyx"),
    )  