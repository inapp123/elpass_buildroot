#!/bin/sh

set -e

# genimage will need to find the extlinux.conf
# in the binaries directory

BOARD_DIR="$(dirname "$0")"

UBOOT_MKIMAGE="$(find "${BUILD_DIR}" -maxdepth 3 -path '*/tools/mkimage' 2>/dev/null | head -n1)"
if [ -z "${UBOOT_MKIMAGE}" ]; then
	UBOOT_MKIMAGE="${HOST_DIR}/usr/bin/mkimage"
fi
export PATH="${HOST_DIR}/usr/bin:${PATH}"

install -m 0644 -D "${BOARD_DIR}/extlinux.conf" "${BINARIES_DIR}/extlinux.conf"

# PL bitstream: Vivado 导出的 system.bit 打进 FIT，由 SPL 在加载 U-Boot 前烧录 PL。
if [ -f "${BOARD_DIR}/system.bit" ]; then
	install -m 0644 -D "${BOARD_DIR}/system.bit" "${BINARIES_DIR}/system.bit"
else
	echo "ERROR: ${BOARD_DIR}/system.bit 不存在 —— 请把 Vivado 导出的 .bit 改名为 system.bit 放进该目录" >&2
	exit 1
fi

UBOOT_NODTB="${BUILD_DIR}/uboot-custom/u-boot-nodtb.bin"
if [ ! -f "${UBOOT_NODTB}" ]; then
	UBOOT_NODTB="$(find "${BUILD_DIR}" -maxdepth 2 -name 'u-boot-nodtb.bin' | head -n1)"
fi
if [ -z "${UBOOT_NODTB}" ] || [ ! -f "${UBOOT_NODTB}" ]; then
	echo "ERROR: 找不到 u-boot-nodtb.bin，请先完成 U-Boot 编译" >&2
	exit 1
fi

if [ ! -f "${BINARIES_DIR}/elpass.dtb" ]; then
	echo "ERROR: ${BINARIES_DIR}/elpass.dtb 不存在，请先完成内核/设备树编译" >&2
	exit 1
fi

install -m 0644 -D "${UBOOT_NODTB}" "${BINARIES_DIR}/u-boot-nodtb.bin"
install -m 0644 -D "${BOARD_DIR}/u-boot-fpga.its" "${BINARIES_DIR}/u-boot-fpga.its"

(
	cd "${BINARIES_DIR}" || exit 1
	"${UBOOT_MKIMAGE}" -f u-boot-fpga.its u-boot.img
)

rm -f "${BINARIES_DIR}/u-boot-fpga.its" "${BINARIES_DIR}/u-boot-nodtb.bin"
