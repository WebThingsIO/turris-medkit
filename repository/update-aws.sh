#!/bin/bash

# set -x

AWS_SUBDIR="openwrt-packages/turris-omnia"
AWS_DIR="s3://mozillagatewayimages/${AWS_SUBDIR}/"
echo "Copying OpenWRT repository files to '${AWS_DIR}'"

aws s3 cp --recursive --exclude '*' --include 'Packages*' --include '*.ipk' --acl=public-read . ${AWS_DIR}
aws s3 ls ${AWS_DIR}

echo "AWS URL"
echo "https://s3-us-west-1.amazonaws.com/mozillagatewayimages/${AWS_SUBDIR}/"
