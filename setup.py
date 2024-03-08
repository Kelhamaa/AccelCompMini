from setuptools import setup
from Cython.Build import cythonize

setup(
    name="LebwohlLasher_Cython",
    ext_modules=cythonize("LebwohlLasher_pyx.pyx"),
    )  