import sys
import LebwohlLasher_Nump_Cyth

def main():
    # Set your program name
    program = "LebwohlLasher"
    # Set the number of Monte Carlo steps
    nsteps = 50
    # Set the side length of the lattice
    nmax = 50
    # Set the reduced temperature
    temp = 0.5
    # Set the plot flag
    pflag = 0

    # Call the main function from your Cython module
    LebwohlLasher_Nump_Cyth.main(program, nsteps, nmax, temp, pflag)

if __name__ == "__main__":
    main()
