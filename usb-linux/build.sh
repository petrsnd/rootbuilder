#!/bin/bash

BUILDROOT_VERSION='2016.08.1'
BUILDROOT_URL="http://buildroot.uclibc.org/downloads/buildroot-${BUILDROOT_VERSION}.tar.gz"

SCRIPT_DIR="$(cd $(dirname $0) && pwd)"
BUILDROOT_DIR="$SCRIPT_DIR/buildroot-$BUILDROOT_VERSION"
CONFIG_FILE=usb-linux.config
KERNEL_CONFIG_FILE=linux-kernel.config

. $SCRIPT_DIR/../buildroot-common/build.sh
