import sys
import LebwohlLasher_cdef_real

def main():
    if len(sys.argv) != 5:
        print("Usage: python3 run.py <nmax> <nsteps> <temp> <pflag>")
        sys.exit(1)

    try:
        nsteps = int(sys.argv[1])
        nmax = int(sys.argv[2])
        temp = float(sys.argv[3])
        pflag = int(sys.argv[4])
    except ValueError:
        print("Invalid input. Please provide integers for nmax and nsteps, and a float for temp.")
        sys.exit(1)

    program = "LebwohlLasher"
    LebwohlLasher_cdef_real.main(program, nsteps, nmax, temp, pflag)

if __name__ == "__main__":
    main()
