#!/bin/bash
#REPODIR=$(cd $(dirname $0) ; pwd)
#cd $REPODIR/flann

#rm -rf build
export ORIGDIR=$(pwd)
export FLANNDIR=$ORIGDIR
#export FLANNDIR=~/code/flann

python2.7 -c "import utool as ut; print('keeping build dir' if not ut.get_argflag('--rmbuild') else ut.delete('build'))" $@

echo 'Removing old build'
rm -rf build
rm -rf CMakeFiles
rm -rf CMakeCache.txt
rm -rf cmake_install.cmake

mkdir -p build

#sudo apt-get install libhdf5-serial-1.8.4
#libhdf5-openmpi-dev

cd build

#sudo apt-get install libcr-dev mpich2 mpich2-doc

# Grab correct python executable
export PYEXE=$(which python2.7)
export PYTHON_EXECUTABLE=$($PYEXE -c "import sys; print(sys.executable)")
if [[ "$VIRTUAL_ENV" == ""  ]]; then
    export LOCAL_PREFIX=/opt/local
    export _SUDO="sudo"
else
    export LOCAL_PREFIX=$($PYEXE -c "import sys; print(sys.prefix)")/local
    export _SUDO=""
fi

echo "PYEXE              = $PYEXE"
echo "PYTHON_EXECUTABLE  = $PYTHON_EXECUTABLE"
echo "LOCAL_PREFIX       = $LOCAL_PREFIX"
echo "_SUDO              = $_SUDO"

# Configure make build install
cmake -G "Unix Makefiles" \
    -DCMAKE_BUILD_TYPE="Release" \
    -DPYTHON_EXECUTABLE=$PYTHON_EXECUTABLE \
    -DBUILD_PYTHON_BINDINGS=On \
    -DBUILD_EXAMPLES=Off \
    -DBUILD_TESTS=Off \
    -DBUILD_MATLAB_BINDINGS=Off \
    -DBUILD_CUDA_LIB=Off \
    -DCMAKE_INSTALL_PREFIX=$LOCAL_PREFIX \
    ..

    #-DNVCC_COMPILER_BINDIR=/usr/bin/gcc \
    #-DCUDA_BUILD_CUBIN=On \
    #-DCUDA_npp_LIBRARY=/usr/local/cuda-6.0/lib64/libnppc.so \
    #-DHDF5_DIR=/home/joncrall/usr \
    #-DHDF5_C_INCLUDE_DIR=/home/joncrall/usr/include \

    #-DCMAKE_VERBOSE_MAKEFILE=On\
    #-DCUDA_VERBOSE_BUILD=On\
    #-DCUDA_NVCC_FLAGS=-gencode;arch=compute_20,code=sm_20;-gencode;arch=compute_20,code=sm_21

cmake .
export NCPUS=$(grep -c ^processor /proc/cpuinfo)
make -j$NCPUS


# Develop pyflann
echo $FLANNDIR
pip install -e $FLANNDIR/src/python

#cd $FLANNDIR/src/python
#python setup.py develop


# Normal install
#pip install $FLANNDIR/src/python
#make install

# pip uninstall flann

cd $FLANNDIR

# Test

python -c "import pyflann; print(pyflann.__file__)"
python -c "import pyflann; print(pyflann)"
python -c "import pyflann" --verbose

flann_setuptools_install()
{
    cd $CODE_DIR/flann/src/python
    #../../build/src/python/setup.py
    python ../../build/src/python/setup.py develop
    sudo python ../../build/src/python/setup.py develop

    python ../../build/src/python/setup.py develop --uninstall
    sudo python ../../build/src/python/setup.py develop --uninstall
}

uninstall_flann()
{
    pip uninstall flann -y

    #"/home/joncrall/venv2/local/lib/python2.7/site-packages"
    export PYSITE=$(python -c "import distutils.sysconfig; print(distutils.sysconfig.get_python_lib())")
    echo $PYSITE

    ls $PYSITE/*flann*

    rm -rf $PYSITE/*flann*
    rm -rf $PYSITE/flann-1.8.4-py2.7.egg
    rm -rf $PYSITE/flann.egg-link

    rm -rf $FLANNDIR/src/python/flann.egg-info
    rm -rf $FLANNDIR/src/python/build
    rm $FLANNDIR/src/python/setup.py

    # Test
    python -c "import pyflann; print(pyflann.__file__)"
    python -c "import pyflann; print(pyflann)"
    python -c "import pyflann" --verbose

    # --------- older commands

    python -m utool search_env_paths --fname '*flann*'

    sudo rm /usr/local/lib/pkgconfig/flann.pc
    rm /home/joncrall/venv2/lib/libflann*
    sudo rm /usr/local/lib/libflann*

    cat $PYSITE/easy-install.pth | grep flann
    sed -i '/flann/d' /home/joncrall/venv2/lib/python2.7/site-packages/easy-install.pth

    python -c "import pyflann; print(pyflann.FLANN.add_points)"
    python -c "import pyflann; print(pyflann.__tmp_version__)"

    ls -al /home/joncrall/venv2/local/lib/python2.7/site-packages/pyflann/lib

    python -c "import pyflann; print(pyflann.__file__)"
    python -c "import pyflann, os.path; print(os.path.dirname(pyflann.__file__))"
    pip list | grep flann
    pip uninstall pyflann -y
    sudo pip uninstall flann
    sudo pip uninstall pyflann

    # The add remove/error branch info
    # Seems to work here: 880433b352d190fcbef78ea95d94ec8324059424
    # Seems to fail here: e5b9cbeabc9f790e231fbb91376a6842207565ba
}

#setupinstall_flann()
#{
#    code
#    cd flann
#    cd src/python
#    python ../../build/src/python/setup.py install
#}

#cd $FLANNDIR/src/python
#cd $ORIGDIR
#$_SUDO python ../../build/src/python/setup.py develop

#$_SUDO make install
#make -j$NCPUS || { echo "FAILED MAKE" ; exit 1; }

#sudo make install || { echo "FAILED MAKE INSTALL" ; exit 1; }

# setup to develop (need to be in python source dir, setup is in build)
# FIXME: messes up the code to find the libflann.so file when using build27
#cd ../src/python
#$_SUDO python ../../build/src/python/setup.py develop
# NODE to use utprof.py you need to have flann sudo installed
#copying pyflann/__init__.py -> build/lib.linux-x86_64-2.7/pyflann
#copying pyflann/flann_ctypes.py -> build/lib.linux-x86_64-2.7/pyflann
#copying pyflann/index.py -> build/lib.linux-x86_64-2.7/pyflann
#copying pyflann/exceptions.py -> build/lib.linux-x86_64-2.7/pyflann
#creating build/lib.linux-x86_64-2.7/pyflann/lib
#copying /home/joncrall/tmp/flann/build/lib/libflann.so -> build/lib.linux-x86_64-2.7/pyflann/lib
#package init file '/home/joncrall/tmp/flann/build/lib/__init__.py' not found (or not a regular file)
#running install_lib
#creating /home/joncrall/venv/lib/python2.7/site-packages/pyflann
#copying build/lib.linux-x86_64-2.7/pyflann/__init__.py -> /home/joncrall/venv/lib/python2.7/site-packages/pyflann
#copying build/lib.linux-x86_64-2.7/pyflann/flann_ctypes.py -> /home/joncrall/venv/lib/python2.7/site-packages/pyflann
#copying build/lib.linux-x86_64-2.7/pyflann/index.py -> /home/joncrall/venv/lib/python2.7/site-packages/pyflann
#creating /home/joncrall/venv/lib/python2.7/site-packages/pyflann/lib
#copying build/lib.linux-x86_64-2.7/pyflann/lib/libflann.so -> /home/joncrall/venv/lib/python2.7/site-packages/pyflann/lib
#copying build/lib.linux-x86_64-2.7/pyflann/exceptions.py -> /home/joncrall/venv/lib/python2.7/site-packages/pyflann
#byte-compiling /home/joncrall/venv/lib/python2.7/site-packages/pyflann/__init__.py to __init__.pyc
#byte-compiling /home/joncrall/venv/lib/python2.7/site-packages/pyflann/flann_ctypes.py to flann_ctypes.pyc
#byte-compiling /home/joncrall/venv/lib/python2.7/site-packages/pyflann/index.py to index.pyc
#byte-compiling /home/joncrall/venv/lib/python2.7/site-packages/pyflann/exceptions.py to exceptions.pyc



debug_flann()
{
    wget http://svn.python.org/projects/python/trunk/Misc/valgrind-python.supp

    sh -c 'cat >> valgrind-python.supp << EOL
{
   ADDRESS_IN_RANGE/Invalid read of size 4
   Memcheck:Addr4
   fun:PyObject_Free
}

{
   ADDRESS_IN_RANGE/Invalid read of size 4
   Memcheck:Value4
   fun:PyObject_Free
}

{
   ADDRESS_IN_RANGE/Conditional jump or move depends on uninitialised value
   Memcheck:Cond
   fun:PyObject_Free
}

{
   ADDRESS_IN_RANGE/Invalid read of size 4
   Memcheck:Addr4
   fun:PyObject_Realloc
}

{
   ADDRESS_IN_RANGE/Invalid read of size 4
   Memcheck:Value4
   fun:PyObject_Realloc
}

{
   ADDRESS_IN_RANGE/Conditional jump or move depends on uninitialised value
   Memcheck:Cond
   fun:PyObject_Realloc
}
EOL'
    valgrind --tool=memcheck --suppressions=valgrind-python.supp python -E -tt ./examples/example.py

    valgrind --tool=memcheck --suppressions=valgrind-python.supp python  ./examples/example.py

}
