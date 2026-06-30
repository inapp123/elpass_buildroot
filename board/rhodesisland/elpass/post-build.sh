#!/bin/sh

# genimage will need to find the extlinux.conf
# in the binaries directory

BOARD_DIR="$(dirname "$0")"

install -m 0644 -D "${BOARD_DIR}/extlinux.conf" "${BINARIES_DIR}/extlinux.conf"

# PL bitstream: 把 Vivado 导出的 system.bit 放进 board 目录,这里拷进镜像目录,
# 让 genimage 打到 boot 分区。U-Boot 的 fpga loadb 会在启动 kernel 前加载它。
if [ -f "${BOARD_DIR}/system.bit" ]; then
	install -m 0644 -D "${BOARD_DIR}/system.bit" "${BINARIES_DIR}/system.bit"
else
	echo "ERROR: ${BOARD_DIR}/system.bit 不存在 —— 请把 Vivado 导出的 .bit 改名为 system.bit 放进该目录" >&2
	exit 1
fi
