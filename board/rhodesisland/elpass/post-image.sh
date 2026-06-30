#!/bin/sh

# By default U-Boot loads DTB from a file named "system.dtb", so
# let's use a symlink with that name that points to the *first*
# devicetree listed in the config.

FIRST_DT=$(sed -nr \
               -e 's|^BR2_LINUX_KERNEL_INTREE_DTS_NAME="(xilinx/)?([-_/[:alnum:]\\.]*).*"$|\2|p' \
               "${BR2_CONFIG}")

if [ -z "${FIRST_DT}" ]; then
	FIRST_DT=$(sed -nr \
	               -e 's|^BR2_LINUX_KERNEL_CUSTOM_DTS_PATH="[^"]*/([-_/[:alnum:]\\.]+)\\.dts[^"]*"$|\1|p' \
	               "${BR2_CONFIG}")
fi

if [ -z "${FIRST_DT}" ]; then
	FIRST_DT=$(find "$(sed -nr \
	                      -e 's|^BR2_LINUX_KERNEL_CUSTOM_DTS_DIR="([^"]+)".*$|\1|p' \
	                      "${BR2_CONFIG}")" -name '*.dts' -printf '%P\n' 2>/dev/null \
	               | head -n1 \
	               | sed 's|\.dts$||')
fi

[ -z "${FIRST_DT}" ] || ln -fs "$(basename "${FIRST_DT}").dtb" "${BINARIES_DIR}/system.dtb"

BOARD_DIR="$(dirname "$0")"

support/scripts/genimage.sh -c "${BOARD_DIR}/genimage.cfg"
