#!/bin/bash

source "${BASEDIR}/scripts/platform.inc"
source "${BASEDIR}/scripts/lib_versions.inc"
source "${BASEDIR}/scripts/util.inc"

# 2025.01.28 ignore the specified version
# and grab the version number from the downloaded file
#libpng-1.6.47.tar.xz

THIS="libpng"
# remove the dots with sed
#PNG_VERSION=$(echo ${libpng_VERSION} | sed 's/\.//g')
URL_ROOT="https://sourceforge.net/projects/${THIS}/files/latest/download"
ARCHIVE_DESTINATION=${THIS}
FILE_DIRECTORY="../../thirdparty/${THIS}/src"

function unxzBinary
{
	echo "Untarring ${THIS}.tar"
	unzip -o "${THIS}.tar" -d "lpng"
	# retrieve the latest version number (1647)
	PNG_LATEST=$(echo `ls lpng` | sed 's/[^0-9]//g')
	ARCHIVE_DESTINATION="${THIS}${PNG_LATEST}/lpng${PNG_LATEST}"
	mv "libpng.tar" "libpng${PNG_LATEST}.tar"
	echo "ARCHIVE_DESTINATION= ${ARCHIVE_DESTINATION}"
	echo "Renaming lpng to ${THIS}${PNG_LATEST}"
	mv lpng "${THIS}${PNG_LATEST}"
	# now we should have a directory named libpng1647
}

fetchBinary
unxzBinary
buildLibrary
