# Common script functions

# Download url to file
function fetchUrl {
	URL=$1
	SAVEPATH=$2

	# Download using an HTTP client of some variety
	if $(which curl 1>/dev/null 2>/dev/null) ; then
		curl --fail -L "${URL}" -o "${SAVEPATH}"
	elif $(which wget 1>/dev/null 2>/dev/null) ; then
		wget "${URL}" -O "${SAVEPATH}"
	else
		# Perl as a last resort (useful for Cygwin)
		perl -MLWP::Simple -e "getstore('${URL}', '${SAVEPATH}') == 200 or exit 1"
	fi
}

function fetchBinary
{
	cd "${BUILDDIR}"

	if [ ! -d "$THIS" ] ; then
		if [ ! -e "$ARCHIVE_DESTINATION" ] ; then
			echo "Fetching ${THIS} source"
			fetchUrl "${URL_ROOT}" "${ARCHIVE_DESTINATION}.tar"
			if [ $? != 0 ] ; then
				echo "downloading ${URL_ROOT} failed"
				if [ -e "${ARCHIVE_DESTINATION}" ] ; then 
					rm ${ARCHIVE_DESTINATION} 
				fi
				exit
			fi
		fi # check for already downloaded source
	fi # check for destination directory
}

function untarBinary
{
#	if [ ! -d "${CEF_UNPACKED_DIR}/Debug" ] ; then
		echo "Unpacking ${THIS} source"
		tar -xf "${ARCHIVE_DESTINATION}.tar"
#	fi
}

function unzipBinary
{
#	if [ ! -d "${CEF_UNPACKED_DIR}/Debug" ] ; then
		echo "Unpacking ${THIS} source"
		unzip "${ARCHIVE_DESTINATION}.zip"
#	fi
}

# run cmake
# run make
# copy files if we have a newer version
function buildLibrary {
	pushd "${BUILDDIR}/${ARCHIVE_DESTINATION}"
	cmake .
	popd
#	cp -u "${BUILDDIR}/${ARCHIVE_DESTINATION}"/*.h ../../thirdparty/${THIS}/src
#	cp -u "${BUILDDIR}/${ARCHIVE_DESTINATION}"/*.c ../../thirdparty/${THIS}/src
	cp -u ${BUILDDIR}/${ARCHIVE_DESTINATION}/*.h ${FILE_DIRECTORY}
	cp -u ${BUILDDIR}/${ARCHIVE_DESTINATION}/*.c ${FILE_DIRECTORY}
}

