#!/bin/bash
set -e


# You should run this script in a clean folder 
# INSTALL_DIR=${PWD}/programs
INSTALL_DIR=
BuildMPI=yes
CompileWithIntel=no
PLUMED_VERSION=2.6.2
Make_CPUs=4
PLUMED_CONFIG_OPT="--enable-modules=all " 

# In some cases you might need to specfiy the compiler, then uncomment this line
# CXX=mpic++

# Compiler settings that seem to work with Intel compilers like the ones 
# on the MPIP Linux workstations
# I would recommend using the default gcc compiler but if you want to use the
# Intel ones, see CompileWithIntel above to yes
if [[ ${CompileWithIntel} == "yes" ]];
then
  CXX=mpicxx
  CC=mpicc
  FC=mpifc
  CPPFLAGS="-I${MKLROOT}/include"
  LDFLAGS="-L${MKLROOT}/lib/intel64" 
  LIBS="-mkl"
  CXXFLAGS="-fp-model precise -fma -align -finline-functions -no-prec-div -qoverride-limits"
  PLUMED_CONFIG_OPT+="--disable-ld-r "
fi

if [[ ${BuildMPI} == "no" ]];
then
  PLUMED_CONFIG_OPT+="--disable-mpi"
fi

# Download and build PLUMED2
wget https://github.com/plumed/plumed2/archive/v${PLUMED_VERSION}.zip
unzip v${PLUMED_VERSION}.zip
rm -f  v${PLUMED_VERSION}.zip

cd plumed2-${PLUMED_VERSION}

if [[  -z ${INSTALL_DIR} ]];
then 
  INSTALL_DIR=${PWD}/install 
fi

./configure  \
  --prefix=${INSTALL_DIR} \
     ${PLUMED_CONFIG_OPT}
make -j ${Make_CPUs}
make install 
cd ..

if [[ $(uname) == Darwin ]]; then
  SOEXT=dylib
else 
  SOEXT=so
fi


cat << EOF > source-plumed.sh
export PLUMED_INSTALL_DIR=${INSTALL_DIR}
export PATH=\${PLUMED_INSTALL_DIR}/bin:\${PATH}
export INCLUDE=\${PLUMED_INSTALL_DIR}/include:\${INCLUDE}
export CPATH=\${PLUMED_INSTALL_DIR}/include:\${CPATH}
export LIBRARY_PATH=\${PLUMED_INSTALL_DIR}/lib:\${LIBRARY_PATH}
export LD_LIBRARY_PATH=\${PLUMED_INSTALL_DIR}/lib:\${LD_LIBRARY_PATH}
export PKG_CONFIG_PATH=\${PLUMED_INSTALL_DIR}/lib/pkgconfig:\${PKG_CONFIG_PATH}
export PLUMED_KERNEL=\${PLUMED_INSTALL_DIR}/lib/libplumedKernel.${SOEXT}
EOF
chmod a+x source-plumed.sh
echo ""
echo "build-plumed.sh: PLUMED has been installed in ${INSTALL_DIR}"
echo "build-plumed.sh:: You need to use "source source-plumed.sh" to load all the variables related to PLUMED" 




