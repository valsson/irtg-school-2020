# TRR 146 IRTG School 2020 - Metadynamics Tutorial

## Build script to download and install PLUMED and LAMMPS

- You should run these script in a clean folder. 
- The scripts have been tested on Linux and MacOS (using mpi from homebrew), and should work out of the box for most standard setups. 
- First run `build-plumed.sh` to download and install PLUMED. 
- This will build PLUMED in the folder `plumed2-2.x.y` and install the PLUMED binaries and libaries in the folder specfied by the `INSTALL_DIR` variables. If `INSTALL_DIR` is not set, they will be installed in `plumed2-2.x.y/install`.
- The `build-plumed.sh` will create a file called `source-plumed.sh` with all the environmental variables related to PLUMED. **You need to load this file by using `source source-plumed.sh` before the next step of building LAMMPS.**
- Then run `build-lammps.sh` to download and install LAMMPS. This script will patch and link LAMMPS with PLUMED. 
- The LAMMPS binary will be copied to the same folder as the PLUMED binary.
- You always need to load the environmental variables using `source source-plumed.sh`, then the PLUMED and LAMMPS binaries are always in the path. 


