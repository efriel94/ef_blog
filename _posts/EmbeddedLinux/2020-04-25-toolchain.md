---
layout: post
title: "Building a toolchain with crosstool-NG"
author: "Emmet Friel"
categories: rpiembedded
image: rpi-linux/toolchain.jpg
---

<br>

## Toolchain - crosstool-NG
Crosstool-NG provides a sleek menu-driven configuration window and it allows you to see the toolchain being built from scratch as well as providing meaningful error messages. It would have been easier to use a build system such as Yocto or Buildroot as those tools encapsulate all the complexity and also generates a toolchain as part of the build. The thing with build systems is if you don’t have a basic understanding of what’s going on under the hood then prepare for a steep learning curve.

## Installation

```bash
sudo apt-get install python3-dev python2.7-dev libncurses5-dev automake libsdl1.2-dev bison chrpath git  g++ gawk texinfo libtool-bin flex gperf lbexpat1-dev
```

Download the latest stable tarball release: <a href="https://crosstool-ng.github.io/download/" target="_blank_">https://crosstool-ng.github.io/download/</a>
Unpack the tarball and build the source code:

```bash
emmet@homepc:/home/emmet/Downloads$ tar -xvf crosstool-ng-1.24.0
emmet@homepc:/home/emmet/Downloads$ cd crosstool-ng-1.24.0/
emmet@homepc:/home/emmet/Downloads/crosstool-ng-1.24.0$ ./configure --enable-local (Build in the local directory, avoiding the need for super user permissions to install in its default directory: /usr/local/bin
emmet@homepc:/home/emmet/Downloads/crosstool-ng-1.24.0$ make
emmet@homepc:/home/emmet/Downloads/crosstool-ng-1.24.0$ make install
 ```

Notes on the commands:

- **configure**: Responsible for getting everything ready prior to the build such as checking dependencies and other programs that are required to build the software. It produces a custom Makefile specific to your machine from a template thats included in the tarball Makefile.in
- **make**: This will run a series of tasks defined in the Makefile that will build the software from its source code.
- **make install**: This will copy the built program with its libraries and documentation into the correct location.

## Selecting the toolchain
The toolchain is hardware specific, built to the specifications of the target CPU and referring to the book this includes:
 - **CPU Architecture**: In the case of the RPi 3B it has a Quad core A53 processor and that is based on the Arm V8 64 bit instruction set.
 - **Endian operation**: The order of bytes within a binary representation. Big endian operation places the MSF byte first and small endian is the opposite (assuming “first is on the left). In this case, Rpi 3B spec outlines it supports both operations. 
 - **Floating point**: For the RPi 3B, it has floating point hardware coprocessor.
 - **Application Binary Interface (ABI)**: The set of rules that mandate how executables are built (data type and size, stack alignment, language-specific constructs, etc.) and behave (calling convention, system call number and invocation mechanisms, etc.)

You can list all the toolchain samples for different architectures using ./ct-ng:

```bash
emmet@homepc:/home/emmet/Downloads/crosstool-ng-1.24.0$ ./ct-ng help #LISTS ALL THE OPTIONS
emmet@homepc:/home/emmet/Downloads/crosstool-ng-1.24.0$ ./ct-ng list-samples
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

This list highlights all the various toolchains and you can see there are different combinations of the same toolchain. The one that I selected is aarch64-rpi3-linux-gnu and I will show how to perform a sanity check to make sure this is the correct compiler. Next step is to select that toolchain, configure it and build.

```bash
emmet@homepc:/home/emmet/Downloads/crosstool-ng-1.24.0$ ./ct-ng aarch64-rpi3-linux-gnu #SELECT
emmet@homepc:/home/emmet/Downloads/crosstool-ng-1.24.0$ ./ct-ng menuconfig #CONFIGURE
```

Few modifications I did was:
**In Paths and misc options**
- ```(${HOME}/x-tools/${CT_TARGET}) #Prefix directory```
- ```(4) Number of parallel jobs #twice the number of cores on my machine```

```bash
emmet@homepc:/home/emmet/Downloads/crosstool-ng-1.24.0$ ./ct-ng build #BUILD
```
The build time will depend on your host specs but it took my Ubuntu 18 VM with 4GB RAM and 2 cores to build it in 40 minutes. Once the build is complete, you will have your sparkling new toolchain in the prefix directory you set.

```bash
emmet@homepc:/home/emmet/x-tools/aarch64-rpi3-linux-gnu$ ls
aarch64-rpi3-linux-gnu  bin  build.log.bz2  include  lib  libexec  share
```

## Sanity Check
You can now check if the toolchain is correct for the Raspberry Pi by compiling a simple hello world program, copying the binary over onto the target and verify it can execute successfully.

```bash
emmet@homepc:/home/emmet$ PATH=~/x-tools/aarch64-rpi3-linux-gnu/bin/:$PATH #Add the toolchain directory to your PATH
emmet@homepc:/home/emmet$ aarch64-rpi3-linux-gnu-gcc --version
aarch64-rpi3-linux-gnu-gcc (crosstool-NG 1.24.0) 8.3.0
Copyright (C) 2018 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
```

Full toolchain configuration: ```emmet@homepc:/home/emmet$ aarch64-rpi3-linux-gnu-gcc -v```

```bash
emmet@homepc:/home/emmet$ cat hello.c 
#include <stdio.h>
int main() {
   printf("Hello, world!\n");
   return 0;
}

emmet@homepc:/home/emmet$ aarch64-rpi3-linux-gnu-gcc -static hello.c -o hello-static #Statically linking the program rather than dynamically
emmet@homepc:/home/emmet$ scp hello-static ubuntu@10.10.10.21:/home/ubuntu
ubuntu@ubuntu-embedded:~$ ./hello-static 
Hello, world!
```

You can see the program executed successfully on the target platform and our toolchain is configured correctly. Next step is to build a bootloader!
