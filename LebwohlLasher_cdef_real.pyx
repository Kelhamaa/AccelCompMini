import sys
import time
import datetime
import numpy as np
cimport numpy as np
import matplotlib.pyplot as plt
import matplotlib as mpl

#=======================================================================
def initdat(int nmax):
    """
    Arguments:
      nmax (int) = size of lattice to create (nmax,nmax).
    Description:
      Function to create and initialise the main data array that holds
      the lattice.  Will return a square lattice (size nmax x nmax)
      initialised with random orientations in the range [0,2pi].
    Returns:
      arr (float[nmax, nmax]) = array to hold lattice.
    """
    arr = np.random.random((nmax, nmax)) * 2.0 * np.pi
    return arr.astype(np.float32)

#=======================================================================
def plotdat(arr, pflag, nmax):
    """
    Arguments:
        arr (float(nmax,nmax)) = array that contains lattice data;
        pflag (int) = parameter to control plotting;
        nmax (int) = side length of square lattice.
    Description:
        Function to make a pretty plot of the data array.  Makes use of the
        quiver plot style in matplotlib.  Use pflag to control style:
          pflag = 0 for no plot (for scripted operation);
          pflag = 1 for energy plot;
          pflag = 2 for angles plot;
          pflag = 3 for black plot.
        The angles plot uses a cyclic color map representing the range from
        0 to pi.  The energy plot is normalised to the energy range of the
        current frame.
      Returns:
        NULL
    """
    cdef int i
    if pflag == 0:
        return

    arr_np = np.array(arr)  # Convert memory view slice to NumPy array

    u = np.cos(arr_np)
    v = np.sin(arr_np)
    x = np.arange(nmax)
    y = np.arange(nmax)
    cols = np.zeros((nmax, nmax))

    if pflag == 1:  # colour the arrows according to energy
        mpl.rc('image', cmap='rainbow')
        for i in range(nmax):
            for j in range(nmax):
                cols[i, j] = one_energy(arr_np, i, j, nmax)
        norm = plt.Normalize(cols.min(), cols.max())
    elif pflag == 2:  # colour the arrows according to angle
        mpl.rc('image', cmap='hsv')
        cols = arr_np % np.pi
        norm = plt.Normalize(vmin=0, vmax=np.pi)
    else:
        mpl.rc('image', cmap='gist_gray')
        cols = np.zeros_like(arr_np)
        norm = plt.Normalize(vmin=0, vmax=1)

    quiveropts = dict(headlength=0, pivot='middle', headwidth=1, scale=1.1 * nmax)
    fig, ax = plt.subplots()
    q = ax.quiver(x, y, u, v, cols, norm=norm, **quiveropts)
    ax.set_aspect('equal')
    plt.show()

#=======================================================================
def savedat(float[:, ::1] arr, int nsteps, float Ts, float runtime, ratio, energy, order, int nmax):
    """
    Arguments:
      arr (float[nmax, nmax]) = array that contains lattice data;
      nsteps (int) = number of Monte Carlo steps (MCS) performed;
      Ts (float) = reduced temperature (range 0 to 2);
      ratio (float[nsteps]) = array of acceptance ratios per MCS;
      energy (float[nsteps]) = array of reduced energies per MCS;
      order (float[nsteps]) = array of order parameters per MCS;
      nmax (int) = side length of square lattice to simulated.
    Description:
      Function to save the energy, order, and acceptance ratio
      per Monte Carlo step to a text file.  Also saves run data in the
      header.  Filenames are generated automatically based on
      date and time at the beginning of execution.
    Returns:
      NULL
    """
    cdef str current_datetime, filename
    # Create filename based on current date and time.
    current_datetime = datetime.datetime.now().strftime("%a-%d-%b-%Y-at-%I-%M-%S%p")
    filename = "LL-Output-{:s}.txt".format(current_datetime)
    with open(filename, "w") as FileOut:
        # Write a header with run parameters
        print("#=====================================================", file=FileOut)
        print("# File created:        {:s}".format(current_datetime), file=FileOut)
        print("# Size of lattice:     {:d}x{:d}".format(nmax, nmax), file=FileOut)
        print("# Number of MC steps:  {:d}".format(nsteps), file=FileOut)
        print("# Reduced temperature: {:5.3f}".format(Ts), file=FileOut)
        print("# Run time (s):        {:8.6f}".format(runtime), file=FileOut)
        print("#=====================================================", file=FileOut)
        print("# MC step:  Ratio:     Energy:   Order:", file=FileOut)
        print("#=====================================================", file=FileOut)
        # Write the columns of data
        for i in range(nsteps + 1):
            print("   {:05d}    {:6.4f} {:12.4f}  {:6.4f} ".format(i, ratio[i], energy[i], order[i]), file=FileOut)

#=======================================================================
def one_energy(float[:, ::1] arr, int ix, int iy, int nmax):
    cdef float en = 0.0
    cdef int ixp, ixm, iyp, iym
    cdef float ang
    ixp = (ix + 1) % nmax
    ixm = (ix - 1) % nmax
    iyp = (iy + 1) % nmax
    iym = (iy - 1) % nmax
    ang = arr[ix, iy] - arr[ixp, iy]
    en += 0.5 * (1.0 - 3.0 * np.cos(ang) ** 2)
    ang = arr[ix, iy] - arr[ixm, iy]
    en += 0.5 * (1.0 - 3.0 * np.cos(ang) ** 2)
    ang = arr[ix, iy] - arr[ix, iyp]
    en += 0.5 * (1.0 - 3.0 * np.cos(ang) ** 2)
    ang = arr[ix, iy] - arr[ix, iym]
    en += 0.5 * (1.0 - 3.0 * np.cos(ang) ** 2)
    return en

#=======================================================================
def all_energy(float[:, ::1] arr, int nmax):
    cdef float enall = 0.0
    cdef int i, j
    for i in range(nmax):
        for j in range(nmax):
            enall += one_energy(arr, i, j, nmax)
    return enall

#=======================================================================
def get_order(float[:, ::1] arr, int nmax):
    cdef Qab
    cdef delta
    cdef lab
    cdef int a, b, i, j
    cdef float max_eigenvalue
    Qab = np.zeros((3, 3), dtype=np.float32)
    delta = np.eye(3, dtype=np.float32)
    lab = np.vstack((np.cos(arr), np.sin(arr), np.zeros_like(arr))).reshape(3, nmax, nmax)
    for a in range(3):
        for b in range(3):
            for i in range(nmax):
                for j in range(nmax):
                    Qab[a, b] += 3 * lab[a, i, j] * lab[b, i, j] - delta[a, b]
    Qab = Qab / (2 * nmax * nmax)
    eigenvalues, eigenvectors = np.linalg.eig(Qab)
    max_eigenvalue = eigenvalues.max()
    return max_eigenvalue

#=======================================================================
def MC_step(float[:, ::1] arr, float Ts, int nmax):
    cdef float scale, accept, ang, en0, en1, boltz
    cdef np.ndarray[np.int_t, ndim=2] xran, yran
    cdef np.ndarray[float, ndim=2] aran
    cdef int i, j, ix, iy
    scale = 0.1 + Ts
    accept = 0
    xran = np.random.randint(0, high=nmax, size=(nmax, nmax))
    yran = np.random.randint(0, high=nmax, size=(nmax, nmax))
    aran = np.random.normal(scale=scale, size=(nmax, nmax)).astype(np.float32)
    for i in range(nmax):
        for j in range(nmax):
            ix = xran[i, j]
            iy = yran[i, j]
            ang = aran[i, j]
            en0 = one_energy(arr, ix, iy, nmax)
            arr[ix, iy] += ang
            en1 = one_energy(arr, ix, iy, nmax)
            if en1 <= en0:
                accept += 1
            else:
                boltz = np.exp(-(en1 - en0) / Ts)
                if boltz >= np.random.uniform(0.0, 1.0):
                    accept += 1
                else:
                    arr[ix, iy] -= ang
    return accept / (nmax * nmax)

#=======================================================================
def main(str program, int nsteps, int nmax, float temp, int pflag):
    cdef float[:, ::1] lattice
    cdef float[:] energy
    cdef float[:] ratio
    cdef float[:] order
    cdef float runtime
    lattice = initdat(nmax)
    plotdat(lattice, pflag, nmax)
    energy = np.zeros(nsteps + 1, dtype=np.float32)
    ratio = np.zeros(nsteps + 1, dtype=np.float32)
    order = np.zeros(nsteps + 1, dtype=np.float32)
    energy[0] = all_energy(lattice, nmax)
    ratio[0] = 0.5
    order[0] = get_order(lattice, nmax)
    initial = time.time()
    for it in range(1, nsteps + 1):
        ratio[it] = MC_step(lattice, temp, nmax)
        energy[it] = all_energy(lattice, nmax)
        order[it] = get_order(lattice, nmax)
    final = time.time()
    runtime = final - initial
    print("{}: Size: {:d}, Steps: {:d}, T*: {:5.3f}: Order: {:5.3f}, Time: {:8.6f} s".format(program, nmax, nsteps, temp,
                                                                                            order[nsteps - 1], runtime))
    savedat(lattice, nsteps, temp, runtime, ratio, energy, order, nmax)
    plotdat(lattice, pflag, nmax)

#=======================================================================
# Main part of program, getting command line arguments and calling
# main simulation function.
#
if __name__ == '__main__':
    if int(len(sys.argv)) == 5:
        PROGNAME = sys.argv[0]
        ITERATIONS = int(sys.argv[1])
        SIZE = int(sys.argv[2])
        TEMPERATURE = float(sys.argv[3])
        PLOTFLAG = int(sys.argv[4])
        main(PROGNAME, ITERATIONS, SIZE, TEMPERATURE, PLOTFLAG)
    else:
        print("Usage: python {} <ITERATIONS> <SIZE> <TEMPERATURE> <PLOTFLAG>".format(sys.argv[0]))
