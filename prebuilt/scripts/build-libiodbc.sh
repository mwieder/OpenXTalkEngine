#!/bin/bash

source "${BASEDIR}/scripts/platform.inc"
source "${BASEDIR}/scripts/lib_versions.inc"
source "${BASEDIR}/scripts/util.inc"

# 2024.07.22 currently ${libiodbcVERSION} is 3.52.5
#libiodbc-3.52.5.tar.xz
#https://sourceforge.net/projects/iodbc/files/latest/download

THIS="libiodbc"
ARCHIVE_DESTINATION="${THIS}-${libiodbc_VERSION}"
#URL_ROOT="https://downloads.sourceforge.net/project/iodbc/iodbc/${libiodbc_VERSION}/${THIS}-${libiodbc_VERSION}.tar.gz"
URL_ROOT="https://sourceforge.net/projects/iodbc/files/latest/download"
FILE_DIRECTORY="../../thirdparty/${THIS}/src"

function copyLibrary {
    mkdir -p "${FILE_DIRECTORY}"
	pushd "${BUILDDIR}/${ARCHIVE_DESTINATION}"
	./configure
	cmakeBinary
	mesonBinary
    popd
	echo "copying files from ${BUILDDIR}/${ARCHIVE_DESTINATION} to ${FILE_DIRECTORY}"
	cp -r ${BUILDDIR}/${ARCHIVE_DESTINATION}/* ${FILE_DIRECTORY}
}

fetchBinary
untarBinary
#unxzBinary
copyLibrary

