#!/bin/sh -e

PREFIX="$1"
shift
OPTIMIZE="$*"
OPTIMIZE1=`echo "$*" | sed -s 's;enable-sse2;enable-sse;'`
echo ${OPTIMIZE}
echo ${OPTIMIZE1}

PFFT_VERSION=1.0.8-alpha-fftw3
TMP="tmp-pfft-$PFFT_VERSION"
LOGFILE="build.log"

# bash check if directory exists
if [ -d $TMP ]; then
        echo "Directory $TMP already exists. Delete it? (y/n)"
	answer='y'
	if [ ${answer} = "y" ]; then
		rm -rf $TMP
	else
		echo "Program aborted."
		exit 1
	fi
fi

mkdir $TMP 
ROOT=`dirname $0`/../
wget https://github.com/rainwoodman/pfft/releases/download/$PFFT_VERSION/pfft-$PFFT_VERSION.tar.gz \
    -O $ROOT/depends/pfft-$PFFT_VERSION.tar.gz 

gzip -dc $ROOT/depends/pfft-$PFFT_VERSION.tar.gz | tar xf - -C $TMP
cd $TMP

(
mkdir double
cd double
../pfft-${PFFT_VERSION}/configure --prefix=$PREFIX --disable-shared --enable-static  \
--disable-fortran --disable-doc --enable-mpi ${OPTIMIZE}
make -j 4 
make install 
) 2>&1 | tee ${LOGFILE}.double |tail

(
mkdir single
cd single
../pfft-${PFFT_VERSION}/configure --prefix=$PREFIX --enable-single --disable-shared --enable-static  \
--disable-fortran --disable-doc --enable-mpi $2 ${OPTIMIZE1}
make -j 4 
make install
) 2>&1 | tee ${LOGFILE}.single | tail

