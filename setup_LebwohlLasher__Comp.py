from setuptools import setup
from Cython.Build import cythonize

setup(
    name="LebwohlLasher_Comp",
    ext_modules=cythonize("LebwohlLasher_Comp.pyx"),
    )  