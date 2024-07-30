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
	echo "Untarring ${ARCHIVE_DESTINATION}.tar"
	tar -xf "${ARCHIVE_DESTINATION}.tar"
}

function unzipBinary
{
	echo "Unzipping ${ARCHIVE_DESTINATION}.zip"
	unzip "${ARCHIVE_DESTINATION}.zip"
}

function unxzBinary
{
	echo "Unzipping ${ARCHIVE_DESTINATION}.tar"
	unzip "${ARCHIVE_DESTINATION}.tar"
}

function cmakeBinary
{
	if [ -e "${BUILDDIR}/${ARCHIVE_DESTINATION}/CMakeLists.txt" ] ; then
		echo "running cmake"
		mkdir -p ${BUILDDIR}/${ARCHIVE_DESTINATION}/build
		pushd "${BUILDDIR}/${ARCHIVE_DESTINATION}"
		cmake -S . -B build
		make
		popd
#		cmake -S "${ARCHIVE_DESTINATION}"
	fi
}

function mesonBinary
{
	if [ -e "${BUILDDIR}/${ARCHIVE_DESTINATION}/meson.build" ] ; then
		echo "running meson and ninja"
		mkdir -p ${BUILDDIR}/${ARCHIVE_DESTINATION}/build
		pushd "${BUILDDIR}/${ARCHIVE_DESTINATION}"
		meson setup --wipe build
		ninja -C build
		popd
	fi
}

# run cmake
# run make
# copy files if we have a newer version
function buildLibrary {
#	if [ -e "${BUILDDIR}/${ARCHIVE_DESTINATION}/CMakeLists.txt" ] ; then
#		pushd "${BUILDDIR}/${ARCHIVE_DESTINATION}"
#		cmake .
#		popd
#	fi
	cmakeBinary
	cp ${BUILDDIR}/${ARCHIVE_DESTINATION}/*.h ${FILE_DIRECTORY}
	cp ${BUILDDIR}/${ARCHIVE_DESTINATION}/*.c ${FILE_DIRECTORY}
}

function buildSrcLibrary {
#	if [ -e "${BUILDDIR}/${ARCHIVE_DESTINATION}/CMakeLists.txt" ] ; then
#		pushd "${BUILDDIR}/${ARCHIVE_DESTINATION}"
#		cmake .
#		popd
#	fi
#	if [ -e "${BUILDDIR}/${ARCHIVE_DESTINATION}/meson.build" ] ; then
#		mkdir ${BUILDDIR}/${ARCHIVE_DESTINATION}/build
#		pushd "${BUILDDIR}/${ARCHIVE_DESTINATION}"
#		meson setup --wipe build
#		ninja -C build
#		popd
#	fi
	cmakeBinary
	mesonBinary
	cp -r ${BUILDDIR}/${ARCHIVE_DESTINATION}/src/*.h ${INCLUDE_DIRECTORY}
	cp -r ${BUILDDIR}/${ARCHIVE_DESTINATION}/src/*.c ${FILE_DIRECTORY}
}

