#!/usr/bin/env bash

set -euo pipefail

# Terminal output colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly CYAN='\033[0;36m'
readonly NORM='\033[0m'

readonly SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
readonly OUT_DIR=$SCRIPT_DIR/out

# Defaults
result=1        # Default to failure

# Loggers
log(){
  printf "%b%s%b\n" "$CYAN" "$1" "$NORM"
}

warning(){
  printf "%b%s%b\n" "$YELLOW" "$1" "$NORM"
}

error(){
  printf "%b%s%b\n" "$RED" "$1" "$NORM"
}

panic() {
  error "$1"
  result=1
  exit 1
}

success(){
  printf "%b%s%b\n" "$GREEN" "$1" "$NORM"
}

# Utilities
cleanup(){
  # Usage: cleanup RESULT
  if [[ "$1" -eq 0 ]]; then
    success PASS
  else
    error FAIL
  fi
}

usage="$(basename "$0") [-h|--help] [-d|--rosdistro string] [-u |--user string] [-v |--version string] [-ws|--workspace string] -- download the needed files to generate QNX RPi image

where:
    -h |--help        show this help text"

# Argparser
while [[ $# -gt 0 ]]
do
  key="$1"

  case $key in
      -h|--help)
      echo "$usage"
      shift 1
      exit
      ;;
      *)
      panic "Unrecognized option $1"
      ;;
  esac
done

# Create trap to make sure all artifacts are removed on exit
trap 'cleanup $result' EXIT

mkdir -p $OUT_DIR && cd $OUT_DIR
wget -q -O bcm2711-rpi-4-b.dtb https://github.com/raspberrypi/firmware/raw/master/boot/bcm2711-rpi-4-b.dtb
wget -q -O fixup4.dat https://github.com/raspberrypi/firmware/raw/master/boot/fixup4.dat
wget -q -O fixup4cd.dat https://github.com/raspberrypi/firmware/raw/master/boot/fixup4cd.dat
wget -q -O fixup4db.dat https://github.com/raspberrypi/firmware/raw/master/boot/fixup4db.dat
wget -q -O fixup4x.dat https://github.com/raspberrypi/firmware/raw/master/boot/fixup4x.dat
wget -q -O start4.elf https://github.com/raspberrypi/firmware/raw/master/boot/start4.elf
wget -q -O start4cd.elf https://github.com/raspberrypi/firmware/raw/master/boot/start4cd.elf
wget -q -O start4db.elf https://github.com/raspberrypi/firmware/raw/master/boot/start4db.elf
wget -q -O start4x.elf https://github.com/raspberrypi/firmware/raw/master/boot/start4x.elf

result=0
exit 0