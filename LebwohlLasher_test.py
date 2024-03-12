import numpy as np
import unittest
import sys
import time
from io import StringIO
# from LebwohlLasher import main
from LebwohlLasher_cdef_real import main

class TestMainFunction(unittest.TestCase):
    def test_main_with_different_nsteps(self):
        # List of nstep values
        nmax_values = [50, 100, 200, 300, 400, 500, 600, 700, 800, 900, 1000]  # Add more values as needed

        # Define your program name, nmax, temp, and pflag here
        program = "YourProgramName"
        nsteps = 50  # Set your desired value
        temp = 1.0  # Set your desired value
        pflag = 0  # Set your desired value

        # Iterate through nstep values and call main function
        for nmax in nmax_values:
            main(program, nsteps, nmax, temp, pflag)

if __name__ == '__main__':
    unittest.main()