---
layout: post
title: "Building an Embedded Linux distro on a Beaglebone Black ARM Cortex-A8"
author: "Emmet Friel"
categories: embedded
image: embedded/Embedded-Linux.png
---

# Introduction

This tutorial will show you how to build the latest kernel 5.5.5 on the Beaglebone Black with a root filesystem less than 10MB that can be easily ported to other boards and IOT devices. Building an embedded Linux distro requires four main elements:

1. Toolchain
- A set of tools required to build and compile your source code that will be able to run on the target device. The tools include a compiler, a linker and various run-time libraries. I will be using a cross-compilation toolchain that will compile the code on my host machine (Ubuntu 18 VM) that then will run on the target (BeagleBone Black).

2. Bootloader
- This initializes the system and loads the kernel into memory. The ability to hand off control to the kernel is achieved through device trees, a data structure (hierarchical nodes which resembles a tree) that defines the hardware.

3. Kernel
- The heart of the operating system. It is responsible for managing resources, interfacing with hardware and it provides an API that allows users to interact with the kernel space from the user space such as shell terminal for example. 

4. Root filesystem
The final element which provides the kernel with the required libraries and program that will be run after kernel initialization. The kernel will either mount the root filesystem in RAM, known as an initial RAM filesystem (initramfs), from the bootloader or it will mount it from a block device such as an SD card or it can be mounted over the network (NFS – Network Filesystem).


# 1. Toolchain: crosstool-NG

Four major components of a toolchain:

1. **GNU Compiler Collection (GCC)** – A collection of compilers used to convert the C/C++/Java etc. into assembly code which is then fed into the assembler.

2. **Binary Utilities** – A set of binary utilities such as the assembler and the linker.

3. **C Standard Library** – The C language is the gateway to the kernel which provides an API defined in POSIX.

4. **GNU Debugger (GDB)** -  Allows to peer inside the program while it is executing to fix bugs.

I will be using the Crosstool-NG to build a custom toolchain as it provides a sleek menu-driven configuration window and it allows you to see the toolchain being built from scratch as well as providing meaningful error messages. It would have been easier to use a build system such as Yocto or Buildroot as those tools encapsulate all the complexity and also generates a toolchain as part of the build though the issue with build systems is if you don’t have a basic understanding of what’s going on under the hood then prepare for a steep learning.

## Dependencies

```bash
sudo apt-get install python3-dev python2.7-dev libncurses5-dev automake libsdl1.2-dev bison chrpath git  g++ gawk texinfo libtool-bin flex gperf lbexpat1-dev
```

## Download & Install

Clone the source code from crosstool-NG’s GitHub repo:

```bash
emmet@homepc:/home/emmet/Documents$ git clone https://github.com/crosstool-ng/crosstool-ng
emmet@homepc:/home/emmet/Documents$ cd crosstool-ng-1.24.0/
emmet@homepc:/home/emmet/Documents/crosstool-ng-1.24.0$ ./bootstrap
emmet@homepc:/home/emmet/Documents/crosstool-ng-1.24.0$ ./configure --enable-local (Build in the local directory, avoiding the need for super user permissions to install in its default directory: /usr/local/bin
emmet@homepc:/home/emmet/Documents/crosstool-ng-1.24.0$ make
emmet@homepc:/home/emmet/Documents/crosstool-ng-1.24.0$ make install
```

Note on some of the commands:

**Configure**: Responsible for getting everything ready prior to the build such as checking dependencies and other programs that are required to build the software. It produces a custom Makefile specific to your machine from a template thats included in the tarball Makefile.in

**Make**: This will run a series of tasks defined in the Makefile that will build the software from its source code.

**Make install**: This will copy the built program with its libraries and documentation into the correct location.


## Choosing the toolchain

Crosstool-NG comes with a list of sample toolchains.

```bash
emmet@homepc:/home/emmet/Documents/crosstool-ng-1.24.0$ ./ct-ng help
emmet@homepc:/home/emmet/Documents/crosstool-ng-1.24.0$ ./ct-ng list-samples
Status  Sample name
[L...]   aarch64-rpi3-linux-gnu
[L..X]   aarch64-unknown-linux-android
[L...]   aarch64-unknown-linux-gnu
[L...]   aarch64-unknown-linux-uclibc
[L...]   alphaev56-unknown-linux-gnu
[L...]   alphaev67-unknown-linux-gnu
[L...]   arc-arc700-linux-uclibc
[L...]   arc-multilib-elf32
[L...]   arc-multilib-linux-uclibc
[L...]   arm-bare_newlib_cortex_m3_nommu-eabi
[L...]   arm-cortex_a15-linux-gnueabihf
[L..X]   arm-cortexa5-linux-uclibcgnueabihf
[L...]   arm-cortex_a8-linux-gnueabi
[L...]   armv7-rpi2-linux-gnueabihf
[L...]   armv8-rpi3-linux-gnueabihf
[L...]   avr
[L...]   i586-geode-linux-uclibc
[L...]   i686-centos6-linux-gnu
[L...]   i686-centos7-linux-gnu
[L...]   i686-nptl-linux-gnu
[L...]   i686-ubuntu12.04-linux-gnu
[L...]   i686-ubuntu14.04-linux-gnu
[L...]   i686-ubuntu16.04-linux-gnu
[L..X]   i686-w64-mingw32
[L...]   m68k-unknown-elf
[L...]   x86_64-ubuntu16.04-linux-gnu
[L...]   x86_64-unknown-linux-gnu
[L...]   x86_64-unknown-linux-uclibc
[L..X]   x86_64-w64-mingw32
[L..X]   xtensa-fsf-elf
[L...]   xtensa-fsf-linux-uclibc
 L (Local)       : sample was found in current directory
 G (Global)      : sample was installed with crosstool-NG
 X (EXPERIMENTAL): sample may use EXPERIMENTAL features
 B (BROKEN)      : sample is currently broken
 O (OBSOLETE)    : sample needs to be upgraded
 ```

 Select and configure the toolchain

```bash
emmet@homepc:/home/emmet/Downloads/crosstool-ng-1.24.0$ ./ct-ng arm-cortex_a8-linux-gnueabi
emmet@homepc:/home/emmet/Downloads/crosstool-ng-1.24.0$ ./ct-ng menuconfig

Paths and misc options  --->
(${HOME}/x-tools/${CT_TARGET}) Prefix directory
[ ] Render toolchain read only (make sure its unchecked)
(4) Number of parallel jobs

Target options  --->
Floating point: (hardware FPU))
(neon) Use specific FPU
# The ARM Cortex-A8 has two coprocessors for floating point operations: neon and vfpv3 which can be found on the technical manual.

Operating System  --->
Version of linux (5.5.5)  ---> 

C-library  ---> 
(--enable-obsolete-rpc) extra config
# required to build the depreciated Sun RPC headers

Save and then Exit.
```

Check the configuration

```bash
emmet@homepc:/home/emmet/Documents/crosstool-ng$ ./ct-ng show-arm-cortex_a8-linux-gnueabi 
[L...]   arm-cortex_a8-linux-gnueabi
    Languages       : C,C++
    OS              : linux-5.5.5
    Binutils        : binutils-2.34
    Compiler        : gcc-9.2.0
    C library       : glibc-2.31
    Debug tools     : duma-2_5_15 gdb-9.1 ltrace-0.7.3 strace-5.5
    Companion libs  : expat-2.2.9 gettext-0.20.1 gmp-6.2.0 isl-0.22 libelf-0.8.13 libiconv-1.16 mpc-1.1.0 mpfr-4.0.2 ncurses-6.2 zlib-1.2.11
    Companion tools :
```

Build the toolchain

The build time will depend on your host specs but it took my Ubuntu 18 VM with 4GB RAM and 2 cores to build it in 40 minutes. Once the build is complete, you will have your sparkling new toolchain in the prefix directory you set.

```bash
emmet@homepc:/home/emmet/Downloads/crosstool-ng-1.24.0$ ./ct-ng build
```

Add the toolchain to your PATH and test
```bash
emmet@homepc:/home/emmet/Documents$ PATH=~/x-tools/arm-cortex_a8-linux-gnueabihf/bin/:$PATH

emmet@homepc:/home/emmet/Documents/u-boot$ arm-cortex_a8-linux-gnueabihf-gcc --version
arm-cortex_a8-linux-gnueabihf-gcc (crosstool-NG 1.24.0) 8.3.0
Copyright (C) 2018 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
```



# 2. Bootloader: U-Boot

Das Universal Bootloader (shortened to U-Boot) is an open source bootloader primarily for embedded devices to define the firmware instructions on how to boot the device's operating system hat supports a wide range of architectures. 

## Prerequisites 

- Using a USB to TTY converter cable to communicate with the board and for debugging. 
- Check if you have the drivers installed, if not then just do a quick search online of these dependencies and install: 
		- modinfo usbserial
		- modinfo cp210x
- Connect pins to the serial debug on the beaglebone board:
		- USB Tx (Green)→ BB Rx
		- USB Rx (Blue) → BB Tx
		- USB GND (Yellow)→ BB GND

![image]({{site.github.url}}/assets/img/embedded/bb-linux/tty-serial.png)

- Power on board
- Connect the USB device filter to the virtual machine

![image]({{site.github.url}}/assets/img/embedded/bb-linux/vbox-usb.png)

- Install picocom to communicate with the beaglebone: ```sudo apt-get install picocom```
- Connect to the beaglebone board: ```sudo picocom -b 115200 /dev/ttyUSB0```


## Download and Configure U-Boot
```bash
emmet@homepc:/home/emmet/Documents$ git clone https://github.com/u-boot/u-boot
emmet@homepc:/home/emmet/Documents$ cd u-boot
emmet@homepc:/home/emmet/Documents/u-boot$ git checkout v2020.04
emmet@homepc:/home/emmet/Documents/uboot$ git checkout -b u-boot-bb
```

Now choose the U-boot configuration based on the Beaglebone Black's processor i.e.AM335X Arm Cortex A8 and then you will be able to customise the configuration from the menu driven window. Lots of config files for various boards can be found in the /configs directory. 

```bash
emmet@homepc:/home/emmet/Documents/u-boot$ make CROSS_COMPILE=arm-cortex_a8-linux-gnueabihf- am335x_evm_defconfig
emmet@homepc:/home/emmet/Documents/u-boot$ make menuconfig

#Modifications
(10) delay in seconds before automatically booting (The amount of time we have to interrupt before its boot up)

Command line interface  ---> (emmets_uboot=>  ) Shell prompt

Boot media  ---> [*] Support for booting from SD/EMMC

#Disable falcon mode (CONFIG_SPL_OS_BOOT)
SPL / TPL  ---> [ ] Activate Falcon Mode 
```

## Compile U-Boot
```bash
emmet@homepc:/home/emmet/Documents/u-boot$ make CROSS_COMPILE=arm-cortex_a8-linux-gnueabihf-
```

Once the build finishes, it will generate your secondary program loader (SPL) which is MLO and the third program loader (TPL) files being the U-boot files. SPL is required to be loaded into SRAM from either flash memory, SD card or eMMC as its used as an intermediate stager to initialize main DRAM memory and then load U-Boot since SRAM can’t run a full bootloader due to . We will be loading MLO and U-Boot from an SD card so I am using an 8GB SD card. You need to partition the SD card into two partitions, partition one which will hold our boot files and partition two holding the root filesystem. I used a tool known as GParted for partitioning.

**
|             | Name   | Size | Format | Flags     |
|-------------|--------|------|--------|-----------|
| Partition 1 | boot   | 2GB  | FAT32  | boot, LBA |
| Partition 2 | rootfs | 6GB  | ext4   |           |
|             |        |      |        |           |
**

Copy SPL and TPL files onto boot partition, unmount device and insert SD card into board. Hold down the boot button before powering on the board otherwise the Beaglebone will boot from onboard eMMC storage. 

```bash
emmet@homepc:/home/emmet/Documents/u-boot$ cp MLO u-boot.img /media/emmet/BOOT
emmet@homepc:/home/emmet/Documents/u-boot$ sync
emmet@homepc:/home/emmet/Documents/u-boot$ sudo umount /media/emmet/BOOT 
emmet@homepc:/home/emmet/Documents/u-boot$ sudo umount /media/emmet/root
emmet@homepc:~$ sudo picocom -b 115200 /dev/ttyUSB0 

U-Boot SPL 2020.04 (Jun 15 2020 - 15:29:01 +0100)
Trying to boot from MMC1


U-Boot 2020.04 (Jun 15 2020 - 15:29:01 +0100)

CPU  : AM335X-GP rev 2.1
Model: TI AM335x BeagleBone Black
DRAM:  512 MiB
WDT:   Started with servicing (60s timeout)
NAND:  0 MiB
MMC:   OMAP SD/MMC: 0, OMAP SD/MMC: 1
Loading Environment from FAT... *** Warning - bad CRC, using default environment

<ethaddr> not set. Validating first E-fuse MAC
Net:   eth0: ethernet@4a100000
Warning: usb_ether MAC addresses don't match:
Address in ROM is          de:ad:be:ef:00:01
Address in environment is  0c:ae:7d:0c:4f:f4
 , eth1: usb_ether
Hit any key to stop autoboot:  0 
emmets_uboot=>  
```

# 3. Linux Kernel

The Linux kernel is the core component of the operating system that is responsible for providing an interface to the user space via the C library, interfacing with the hardware using device drivers and lastly, managing resources such as memory, storage and the execution of tasks.

![image]({{site.github.url}}/assets/img/embedded/bb-linux/kernel.png)

## Download the source code
The Linux Kernel main branch is managed by its creator, Linus Torvalds and you can download the source code from GitHub:

```bash
emmet@homepc:/home/emmet/Documents$ git clone https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/
emmet@homepc:/home/emmet/Documents$ cd linux/
emmet@homepc:/home/emmet/Documents/linux$ git checkout v5.5.5
emmet@homepc:/home/emmet/Documents/linux$ git checkout -b kernel-bb-5.5.5 # creates a local branch
```

You can find all the different kernel configuration files based on the architecture in **linux/arch/<architecture>/configs**. The Beaglebone Black is based on the ARM V7 architecture so the configuration we are going to use is: **multi_v7_defconfig**. Clean the project before starting:

```bash
emmet@homepc:/home/emmet/Documents/linux$ make distclean
```

## Configure and build the kernel
Select the ARM V7 kernel configuration and launch the menuconfig window. The different types of architectures that can be supplied can be seen in the arch/ directory. In the case of building the kernel the architecture (ARCH=) has to be expressed in addition to CROSS_COMPILE. 

```bash
emmet@homepc:/home/emmet/Documents/linux$ make ARCH=arm CROSS_COMPILE=arm-cortex_a8-linux-gnueabihf- multi_v7_defconfig
emmet@homepc:/home/emmet/Documents/linux$ make ARCH=arm menuconfig

#Modifications
General setup  ---> (-emmetfriel) Local version - append to kernel release 
General setup  ---> ((beaglebone-ef)) Default hostname
```

Build and compile the kernel:
```bash
emmet@homepc:/home/emmet/Documents/linux$ make ARCH=arm CROSS_COMPILE=arm-cortex_a8-linux-gnueabihf- 
```

Check your new kernel release:
```bash
emmet@homepc:/home/emmet/Documents/linux$ make kernelrelease
5.5.5-emmetfriel
```

The output files are in the ```arch/arm/boot/``` directory. Copy the kernel image (zImage) and the device tree blob ```arch/arm/boot/dts/am335x-boneblack.dtb``` onto the boot partition of the SD card.

```bash
emmet@homepc:/home/emmet/Documents/linux/arch/arm/boot$ cp zImage /media/emmet/BOOT
emmet@homepc:/home/emmet/Documents/linux/arch/arm/boot$ cp dts/am335x-boneblack.dtb /media/emmet/BOOT
```

## Predefining boot parameters using uEnv.txt

U-Boot supports using uEnv.txt which is a text file that declares and initializes boot variables before U-Boot runs bootcmd. Create a file uEnv.txt, insert the contents below and copy it onto the boot partition:

>
>console=ttyS0,115200
>ethaddr=02:f8:7e:a6:fc:e1
>ipaddr=192.168.1.1
>serverip=192.168.1.10
>bootfile=zImage
>fdtfile=am335x-boneblack.dtb
>loadaddr=0x80007fc0
>fdtaddr=0x80F80000
>loadfdt=fatload mmc 0:1 ${fdtaddr} ${fdtfile}
>loaduimage=fatload mmc 0:1 ${loadaddr} ${bootfile}
>mmc_args=setenv bootargs console=${console} ${optargs} root=/dev/mmcblk0p2 rootfstype=ext4
>fdtboot=run mmc_args; bootz ${loadaddr} - ${fdtaddr}
>uenvcmd=mmc rescan; run loaduimage; run loadfdt; run fdtboot;
>

Insert SD card back into the beaglebone and test the kernel:

```bash
[    2.348290] EXT4-fs (mmcblk0p2): mounted filesystem with ordered data mode. Opts: (null)
[    2.356659] VFS: Mounted root (ext4 filesystem) readonly on device 179:2.
[    2.364781] devtmpfs: error mounting -2
[    2.370319] Freeing unused kernel memory: 1024K
[    2.375558] Run /sbin/init as init process
[    2.379760] Run /etc/init as init process
[    2.383803] Run /bin/init as init process
[    2.387893] Run /bin/sh as init process
[    2.391757] Kernel panic - not syncing: No working init found.  Try passing init= option to kernel. See Linux Documentation/admin-guide/init.rst for guidance.
[    2.405995] CPU: 0 PID: 1 Comm: swapper/0 Not tainted 5.5.5-emmetfriel #1
[    2.412809] Hardware name: Generic AM33XX (Flattened Device Tree)
[    2.418969] [<c03124e0>] (unwind_backtrace) from [<c030c6dc>] (show_stack+0x10/0x14)
[    2.426758] [<c030c6dc>] (show_stack) from [<c0daa3e8>] (dump_stack+0xbc/0xd0)
[    2.434027] [<c0daa3e8>] (dump_stack) from [<c0338e60>] (panic+0x110/0x328)
[    2.441026] [<c0338e60>] (panic) from [<c0dc1f50>] (kernel_init+0x108/0x110)
[    2.448109] [<c0dc1f50>] (kernel_init) from [<c03010e8>] (ret_from_fork+0x14/0x2c)
[    2.455709] Exception stack(0xdb0b1fb0 to 0xdb0b1ff8)
[    2.460782] 1fa0:                                     00000000 00000000 00000000 00000000
[    2.468997] 1fc0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
[    2.477208] 1fe0: 00000000 00000000 00000000 00000000 00000013 00000000
[    2.483868] ---[ end Kernel panic - not syncing: No working init found.  Try passing init= option to kernel. See Linux Documentation/admin-guide/init.rst for guidance. ]---
```

The kernel should hang or panic which is expected as there is no root filesystem on the SD card. The root filesystem will now be built using Buildroot.


# Root Filesystem: Buildroot

Buildroot is an embedded Linux build system that supports many processors and architectures able to generate a toolchain, root filesystem, Linux kernel and a bootloader. Since we have built our own toolchain, bootloader and kernel, Buildroot will be used to a create a minimal root filesystem including busybox and simple packages. 

## Clone and Configure Buildroot
```bash
git clone git://git.buildroot.net/buildroot
make beaglebone_defconfig
make menuconfig
```
Modifications:
1. Configure buildroot to use our own toolchain instead of the built-in toolchain
```bash
Toolchain  ---> Toolchain (Custom toolchain)  ---> 
		 (/home/emmet/x-tools/arm-cortex_a8-linux-gnueabihf) Toolchain path
		External toolchain gcc version (9.x)  --→
		External toolchain kernel headers series (5.5.x)  --->
```
2. Personalizing the OS
```bash
System configuration  --->     (buildroot-ef) System hostname
				(Welcome to Emmets Buildroot) System banner
				[*] Enable root login with password
				(password123) Root password
```
3. Disable kernel since we built our own
```bash
Kernel  --->			[ ] Linux Kernel  #we have already built our own kernel
```
4. Enable several packages
```bash
Networking applications  --->	[*] dhcpcd
					            [*] openssh
Text editors and viewers  ---> 	[*] nano
                                [*]   optimize for size
```

## Build the root filesystem
```bash
emmet@homepc:/home/emmet/Documents/buildroot$ make
```

**Error**: If the build throws up an error copy the relevant files illustrated in the error message into buildroot/output/images directory. If the directory doesn’t exist then create it. The build files will be in the ```output/images/``` directory so the next thing is to flash partition 2 of the SD card with the root filesystem.

```bash
emmet@homepc:/home/emmet/Documents/buildroot$ sudo fdisk -l
Device     Boot   Start      End  Sectors  Size Id Type
/dev/sdb1  *       2048  2086911  2084864 1018M  c W95 FAT32 (LBA)
/dev/sdb2       2086912 15564799 13477888  6.4G 83 Linux

emmet@homepc:/home/emmet/Documents/buildroot$ sudo dd if=output/images/rootfs.ext4 of=/dev/sdb2
```

# Booting up the custom Linux OS

Unmount and eject the SD card and place it into the Beaglebone Black and your board will now be running a lightweight custom embedded Linux distro. The image below shows the configured kernel and hostname as well as running the entire root filesystem in under 10MB.

![image]({{site.github.url}}/assets/img/embedded/bb-linux/buildroot.png)




