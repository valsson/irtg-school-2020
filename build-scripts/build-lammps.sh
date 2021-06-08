#!/bin/bash
set -e

BuildMPI=yes
LAMMPS_VERSION=patch_27May2021
Make_CPUs=4


if [[  -z ${PLUMED_KERNEL} ]]; then
  echo "The PLUMED environmental variables seen to be missing"
  echo "Did you run source source-plumed.sh?"
  exit 0
fi

if [[  -z ${PLUMED_INSTALL_DIR} ]]; then
  echo "The PLUMED environmental variables seen to be missing"
  echo "Did you run source source-plumed.sh?"
  exit 0
fi

if  [[ ! -x "$(command -v plumed)" ]]; then
  echo "The plumed command seems to be missing from the path" 
  echo "Did you run source source-plumed.sh?"
  exit 0
fi

if  ! plumed config -q has mpi  && [[ ${BuildMPI} == "yes" ]]; then 
  echo "You are trying to compile LAMMPS with MPI while PLUMED has been compiled without MPI"
  echo "Set BuildMPI to no in the script" 
  exit 0
fi


# Download and build LAMMPS 
if [[ -e ${LAMMPS_VERSION}.zip ]]; then
  echo "the ${LAMMPS_VERSION}.zip that we want to download already exists, please delete it to be sure that the file is properly downloaded"
  exit 0
fi
if [[ -e lammps-${LAMMPS_VERSION} ]]; then
  echo "the lammps-${LAMMPS_VERSION} folder from unzipping the ${LAMMPS_VERSION}.zip already exists, please delete it to be sure that the build is clean"
  exit 0
fi

wget https://github.com/lammps/lammps/archive/${LAMMPS_VERSION}.zip
unzip ${LAMMPS_VERSION}.zip 
rm -f ${LAMMPS_VERSION}.zip 
cd lammps-${LAMMPS_VERSION}


if [[ ${BuildMPI} == "no" ]]; then 
  # Since this version is not compiled with MPI, it should not pass a communicator to PLUMED
  cat src/USER-PLUMED/fix_plumed.cpp | grep -v setMPIComm > src/USER-PLUMED/fix_plumed.cpp.fix
  mv src/USER-PLUMED/fix_plumed.cpp.fix src/USER-PLUMED/fix_plumed.cpp
fi

opt=""

if [[ $(uname) == Darwin ]]; then
  # Fix the name of the PLUMED kernel on OSX
  # cmake:
  cat cmake/CMakeLists.txt | sed "s/libplumedKernel.so/libplumedKernel.dylib/" > cmake/CMakeLists.txt.fix
  mv cmake/CMakeLists.txt.fix cmake/CMakeLists.txt
  # make:
  cat lib/plumed/Makefile.lammps.runtime | sed "s/libplumedKernel.so/libplumedKernel.dylib/" > lib/plumed/Makefile.lammps.runtime.fix
  mv lib/plumed/Makefile.lammps.runtime.fix lib/plumed/Makefile.lammps.runtime
fi

# blas and lapack are not required when PLUMED is linked shared or runtime:
cat cmake/CMakeLists.txt | sed "s/ OR PKG_USER-PLUMED//" > cmake/CMakeLists.txt.fix
mv cmake/CMakeLists.txt.fix cmake/CMakeLists.txt

make -C src lib-plumed args="-p ${INSTALL_DIR} -m runtime"

mkdir build
cd build
cmake -DBUILD_MPI=${BuildMPI} \
      -DPKG_MANYBODY=yes \
      -DPKG_KSPACE=yes \
      -DPKG_MOLECULE=yes \
      -DPKG_RIGID=yes \
      -DPKG_USER-PLUMED=yes \
      -DDOWNLOAD_PLUMED=no \
      -DPLUMED_MODE=runtime \
      $opt \
      ../cmake
make VERBOSE=1 -j ${Make_CPUs}

cp lmp ${PLUMED_INSTALL_DIR}/bin/lmp
echo "build-lammps.sh: LAMMPS has been install as lmp in the same folder as PLUMED"
echo "build-lammps.sh: (${PLUMED_INSTALL_DIR})"
