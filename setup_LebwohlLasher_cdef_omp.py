from setuptools import setup
from Cython.Build import cythonize
from distutils.extension import Extension

ext_modules = [
    Extension(
        "LebwohlLasher_cdef_omp",
        ["LebwohlLasher_cdef_omp.pyx"],
        extra_compile_args=["-fopenmp"],  # Compiler flags for OpenMP
        extra_link_args=["-fopenmp"],     # Linker flags for OpenMP
    )
]

setup(
    ext_modules=cythonize(ext_modules),
)
