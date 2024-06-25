#!/bin/bash

source "${BASEDIR}/scripts/platform.inc"
source "${BASEDIR}/scripts/lib_versions.inc"
source "${BASEDIR}/scripts/util.inc"

# 2023.10.27 currently ${SQLITE_VERSION} is 3.44

SQLITE_ROOT=""
SQLITE_AMALGAMATION="sqlite-amalgamation-${SQLITE_VERSION}0000.zip"
SQLITE_DESTINATION="../thirdparty/libsqlite/${SQLITE_AMALGAMATION}"

# Grab the source for the library
SQL_URL="${SQLITE_ROOT}/${SQLITE_AMALGAMATION}"

function fetchSqlite
{
	cd "${BUILDDIR}"

	if [ ! -d "$CEF_DST" ] ; then
		if [ ! -e "$SQLITE_DESTINATION" ] ; then
			echo "Fetching sqlite source"
			fetchUrl "${SQL_URL}" "${SQLITE_DESTINATION}"
			if [ $? != 0 ] ; then
				echo "downloading ${SQL_URL} failed"
				if [ -e "${SQLITE_DESTINATION}" ] ; then 
					rm ${SQLITE_DESTINATION} 
				fi
				exit
			fi
		fi # check for already downloaded source
	fi # check for destination directory
}

function unzipSqlite
{
	if [ ! -d "${CEF_UNPACKED_DIR}/Debug" ] ; then
		echo "Unpacking sqlite source"
		unzip "${SQLITE_AMALGAMATION}"
	fi
}
			
# just repackage existing prebuilts
function buildSqlite {
	REVDB="${OUTPUT_DIR}/lib/${PLATFORM}/${ARCH}/CEF"
	mkdir -p "${REVDB}"
	cp -a "${CEF_UNPACKED_DIR}/Release/"* "${SQLITE_DESTINATION}"
	cp -a "${CEF_UNPACKED_DIR}/Resources/"* "${SQLITE_DESTINATION}"

	# create a pointer to the thirdparty directory
	# "cp -as" needs an absolute reference, not relative
	SQLITE_SRC_DIR="/thirdparty/libsqlite/"
	pushd "../..${SQLITE_SRC_DIR}"
	pwd > pwd.txt
	SQLITE_THIRDPARTY=`cat pwd.txt`

	popd
#	cd "${BUILDDIR}"
	cp -as ${BUILDDIR}/${CEF_UNPACKED_DIR}/include ${SQLITE_THIRDPARTY}
	cp -as ${BUILDDIR}/${CEF_UNPACKED_DIR}/libcef_dll ${SQLITE_THIRDPARTY}
	cp ${BUILDDIR}/${CEF_UNPACKED_DIR}/*.txt ${SQLITE_THIRDPARTY}
	rm ${SQLITE_THIRDPARTY}/pwd.txt	# clean up the mess afterwards
}

fetchSqlite
unzipSqlite
buildSqlite

