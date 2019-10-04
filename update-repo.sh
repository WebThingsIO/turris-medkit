#!/bin/bash
#
# This script needs usign. You can grab a copy from:
#   git clone https://git.openwrt.org/project/usign.git
#   cd usign
#   mkdir build
#   cd build
#   cmake ..
#   make
#   sudo make install

BUILD_DIR=$(pwd)/../build
MAKE_INDEX="${BUILD_DIR}/scripts/ipkg-make-index.sh"
IPK_DIR="${BUILD_DIR}/bin/packages/arm_cortex-a9_vfpv3/moziot"
USIGN=usign
KEY="moziot-openwrt-sign.key"
REPOSITORY="repository"

export PATH="${PATH}:${BUILD_DIR}/staging_dir/host/bin"

mkdir -p ${REPOSITORY}

PACKAGE_LIST="node-mozilla-iot-gateway python3-gateway-addon python3-singleton-decorator python3-nnpy libnanomsg"
for package in ${PACKAGE_LIST}; do
  echo "Copying ${package} ..."
  rm -f ${REPOSITORY}/${package}*.ipk
  cp ${IPK_DIR}/${package}*.ipk ${REPOSITORY} 
done

( cd ${REPOSITORY}; \
  ${MAKE_INDEX} . > Packages.manifest; \
  grep -vE '^(Maintainer|LicenseFiles|Source|Require)' Packages.manifest > Packages; \
  gzip -9nc Packages > Packages.gz; \
  ${USIGN} -S -m Packages -s ../${KEY}; \
)
