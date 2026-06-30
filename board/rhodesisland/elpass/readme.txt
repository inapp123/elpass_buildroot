Buildroot support for Rhodes Island ArkELPass V1 (elpass) board.

This defconfig is based on the Zynq-7000 ZC702 reference design, adapted
for the custom elpass hardware with board-specific ps7_init, device tree,
and FPGA bitstream support.

Steps to build:

1) make rhodesisland_elpass_defconfig
2) make
3) All needed files will be available in the output/images directory.
   The sdcard.img file is a complete bootable image ready to be written
   on the boot medium:

       # dd if=output/images/sdcard.img of=/dev/sdX

   Where 'sdX' is the device node of the uSD.
4) boot your board

Before building, copy the Vivado-generated bitstream to:

    board/rhodesisland/elpass/system.bit

The post-build script will fail if this file is missing.
It is embedded into u-boot.img as a FIT loadable; SPL programs the PL
before loading U-Boot (CONFIG_SPL_FPGA is enabled in xilinx_zynq_virt).

Board files:

 - elpass.dts          Linux device tree
 - elpass-uboot.dts    U-Boot device tree
 - pl.dtsi             PL 外设 (el_display_engine 等)
 - ps7_init_gpl.c/h    PS7 initialization (from Vivado)
 - system.bit          FPGA bitstream (not in git, add locally)
 - u-boot-fpga.its     FIT source: SPL loads fpga-1 then firmware-1

Boot flow (SD card):

 boot.bin (SPL) -> u-boot.img (FIT: system.bit + U-Boot + DTB) -> extlinux -> kernel

On serial console you should see "FPGA image loaded from FIT" during SPL boot.

You can alter the booting procedure by creating a file uEnv.txt
in the root of the SD card. It is a plain text file in format
<key>=<value> one per line:

kernel_image=myimage
modeboot=myboot
myboot=...
