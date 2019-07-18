-- See https://turris.pages.labs.nic.cz/updater/docs/language.html for syntax
Repository("moziot", "https://s3-us-west-1.amazonaws.com/mozillagatewayimages/openwrt-packages/turris-omnia", { ocsp = false })

Install("node-mozilla-iot-gateway", { repository = {"moziot"} })
Install("kmod-usb-acm", "kmod-usb-serial-ftdi")
