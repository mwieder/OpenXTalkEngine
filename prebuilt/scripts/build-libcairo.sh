#!/bin/bash

source "${BASEDIR}/scripts/platform.inc"
source "${BASEDIR}/scripts/lib_versions.inc"
source "${BASEDIR}/scripts/util.inc"

# 2023.10.27 currently ${libcairo_VERSION} is 1.18.0

THIS="libcairo"
URL_ROOT="https://www.cairographics.org/releases/cairo-${libcairo_VERSION}.tar.xz"
ARCHIVE_DESTINATION="libcairo-${libcairo_VERSION}"

fetchBinary
untarBinary
buildLibrary

