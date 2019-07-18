#!/bin/bash

GATEWAY_VERSION='0.9.0'
PKG_RELEASE='3'
MEDKIT_NAME="omnia-medkit-moziot-${GATEWAY_VERSION}-${PKG_RELEASE}.tar.gz"

V8_VERSION='57'
ARCHITECTURE='openwrt-linux-arm_cortex-a9_vfpv3'
PYTHON_VERSIONS='2.7,3.5'
ADDON_API='2'
ADDON_LIST_URL='https://api.mozilla-iot.org:8443/addons'
PARAMS="?api=${ADDON_API}&arch=${ARCHITECTURE}&node=${V8_VERSION}&python=${PYTHON_VERSIONS}&version=${GATEWAY_VERSION}"
MOZIOT_HOME="/srv/mozilla-iot-home"
OVERLAY_DIR="../overlay"
ADDONS_DIR="${OVERLAY_DIR}${MOZIOT_HOME}/addons"
TEMP_DIR="tmp"

###########################################################################
#
# Retrieves the addon URL from the addon list
#
get_addon_url() {
  addon_list="$1"
  addon_name="$2"
  url=$(cat "${addon_list}" | python3 -c \
    "import json, sys; \
    l = json.loads(sys.stdin.read()); \
    print([p['url'] for p in l if p['name'] == '${addon_name}'][0]);")
  echo "${url}"
}

###########################################################################
#
# Retrieves an addon from the addon list and adds to the overlay
#
install_addon() {
  addon_list="$1"
  addon_name="$2"
  echo "Installing addon ${addon_name} ..."

  addon_url=$(get_addon_url "${addon_list}" "${addon_name}")
  curl -s -L -o "${TEMP_DIR}/${addon_name}.tgz" "${addon_url}"
  tar xzf "${TEMP_DIR}/${addon_name}.tgz" -C "${ADDONS_DIR}"
  mv "${ADDONS_DIR}/package" "${ADDONS_DIR}/${addon_name}"
}

###########################################################################
#
# Main program
#

# Copy in the default addons
rm -rf ${ADDONS_DIR}
mkdir -p "${ADDONS_DIR}"
rm -rf "${TEMP_DIR}"
mkdir -p "${TEMP_DIR}"

echo "Retrieving addon list ..."
addon_list="${TEMP_DIR}/addon-list.json"
curl -s -o "${addon_list}" "${ADDON_LIST_URL}${PARAMS}"

install_addon "${addon_list}" 'zigbee-adapter'
install_addon "${addon_list}" 'zwave-adapter'
install_addon "${addon_list}" 'thing-url-adapter'

# Go and make the medkit
echo "Creating medkit ..."
../../generate_medkit -t omnia -b hbs --updater-script ../moziot.lua -l en --sign ../moziot-openwrt-sign.key --overlay ${OVERLAY_DIR} ${MEDKIT_NAME}
