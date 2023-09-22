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
# commit=master
# commit=afdb60cc1a8a4aa0c6af68f02b6c1efe6256ba5d

# recommanded commit from qnx
# search for Boot Firmware Files Versions into release note
# https://www.qnx.com/developers/articles/rel_6836_0.html
commit=0d458874a89921fbe460e422b239695e1e101e2b

qnx_folder=${HOME}/qnx710
qnx_bsp_file=$qnx_folder/bsp/BSP_raspberrypi-bcm2711-rpi4_br-710_be-710_SVN946248_JBN18.zip

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

if [ -f $qnx_bsp_file ]; then
  echo "file present extracting"
  unzip $qnx_bsp_file images/ifs-rpi4.bin images/tools/sdboot_images/config.txt -d $OUT_DIR -qq
  mv $OUT_DIR/images/ifs-rpi4.bin $OUT_DIR
  mv $OUT_DIR/images/tools/sdboot_images/config.txt $OUT_DIR
  rm -rf $OUT_DIR/images
else
  error FAIL
fi

boot_file_list=(\
  bcm2711-rpi-4-b.dtb \
  start4.elf \
  start4x.elf \
  start4db.elf \
  start4cd.elf \
  fixup4.dat \
  fixup4x.dat \
  fixup4cd.dat \
  fixup4db.dat \
)

for boot_file in "${boot_file_list[@]}";
do
  wget -O $boot_file https://github.com/raspberrypi/firmware/raw/$commit/boot/$boot_file
done

result=0
exit 0