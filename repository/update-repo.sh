#!/bin/bash

SDK=/home/dhylands/Raspbian/turris-sdk/sdk-omnia-stable

MAKE_INDEX="${SDK}/feeds/base/scripts/ipkg-make-index.sh"
USIGN="${SDK}/staging_dir/host/bin/usign"
KEY="../moziot-openwrt-sign.key"

rm -f node-mozilla-iot-gateway_*
cp ${SDK}/bin/mvebu-musl/packages/node/node-mozilla-iot-gateway_0.9.0-4_mvebu.ipk .
${MAKE_INDEX} . > Packages.manifest
grep -vE '^(Maintainer|LicenseFiles|Source|Require)' Packages.manifest > Packages
gzip -9nc Packages > Packages.gz
${USIGN} -S -m Packages -s ${KEY}
