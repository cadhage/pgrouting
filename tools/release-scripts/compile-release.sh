#!/bin/bash

set -e

CPPVERSION=$1

function test_compile {                                                                                                                                                                                                          

echo ------------------------------------
echo ------------------------------------
echo Compiling with $1
echo ------------------------------------

sudo update-alternatives --set gcc /usr/bin/gcc-$1

cd build/
cmake  -DWITH_DOC=ON -DBUILD_DOXY=ON -DCMAKE_BUILD_TYPE=Release .. > tmp_cmake.txt
make > tmp_make.txt 2>tmp_make_err.txt
sudo make install > tmp_make_install.txt
cp lib/pgrouting--2.4.0.sig  ../tools/curr-sig/
cd ..

echo "  - [x] Compilation OK"

tools/testers/algorithm-tester.pl > build/tmp_tests.txt
echo "  - [x] Documentation tests OK"


dropdb --if-exists ___pgr___test___
createdb  ___pgr___test___
sh ./tools/testers/pg_prove_tests.sh vicky > build/tmp_pgtap.txt
dropdb  ___pgr___test___
echo '  - [x] Pgtap tests OK'

if [[ "$1" == "4.8" ]]; then
    cd build
    make doc 
    echo "  - [x] Build Users documentation OK"
    make doxy
    echo "  - [x] Build developers documentation OK"
    cd ..
fi

}

sudo rm -f /usr/lib/postgresql/9.3/lib/libpgrouting-2.4.so
sudo rm -f /usr/share/postgresql/9.3/extension/pgrouting*2.4.0*
rm -rf build/*
test_compile $CPPVERSION

exit 0
