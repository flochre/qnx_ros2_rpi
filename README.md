# qnx_ros2_rpi

## Installing QNX on RPi4

### Requirements
```
RPi4 with SD-Card
USB-TTL Serial Cable -or- Arduino and Jumper Cables
MyQNX Account with QNX license
```

### Install QNX Software Center
Please note you need a license to be able to download.
Download the software center for your system
https://www.qnx.com/download/group.html?programid=29178

In linux use it:
```
chmod +x qnx-setup-2.0-202209011607-linux.run
./qnx-setup-2.0-202209011607-linux.run
```

![QNX SW Center](doc/images/QNX_sw_center.png "QNX SW Center")

Install via Add Installation..

![QNX SW 710](doc/images/install_qnx_sw_dev_710.png "QNX SW 710")

Once install is done add the board RPi4 via Manage Installation

![QNX SW Center](doc/images/QNX_sw_center.png "QNX SW Center")
![QNX SW Install RPi](doc/images/install_rpi_board.png "QNX SW Install RPi")

Inside qnx710 you should have a bsp folder
```
$ l ~/qnx710/bsp/
BSP_raspberrypi-bcm2711-rpi4_br-710_be-710_SVN946248_JBN18.zip
```

### Generate SD-Card
We can now download and unzip all the needed data
clone this repo
```
export QNX_ROOT=${HOME}/workspace
mkdir -p ${WORKSPACE_ROOT} && cd ${WORKSPACE_ROOT}
git clone https://github.com/flochre/qnx_ros2_rpi.git
cd ${WORKSPACE_ROOT}/qnx_ros2_rpi
./generate-sd-card.bash
```

this will generate a out folder that contain what you should copy on the SD-Card
Make sure to format your SD-card in FAT

### Serial Communication
#### With USB-TTL Serial Cable
![RPi-Console-connection](doc/images/learn_raspberry_pi_piconsole_bb.png "RPi-Console-connection")
```
The red lead should not be connected in our case
The black lead to GND (3rd pin down)
The white lead to TXD on the Pi (4th pin down)
The green lead to RXD on the Pi (5th pin down)
```

#### With Arduino
![Arduino-as-TTL-converter](doc/images/USB-to-TTL-converter-using-arduino-UNO-R3.png "Arduino-as-TTL-converter")
```
on Arduino: 
    connect the RESET pin to GND

between Arduino and RPi:
    Link the GND (3rd pin down from RPi) to any GND of the Arduino
    Pin 0 (RX) from Arduino to TX from RPiD (4th pin down)
    Pin 1 (TX) from Arduino to RX from RPiD (5th pin down)
```

#### Use cu to communicate with the Pi

```
sudo apt install opencu
cu -l /dev/ttyUSB0 -s 115200
```
Use `~.` to close the communication



sources:
1. http://www.qnx.com/download/download/56868/SDP710_BSP_UG_RASPBERRYPI_BCM2711_RPI4_Board_20221111.pdf
1. https://www.qnx.com/developers/articles/rel_6836_0.html
1. https://carleton.ca/rcs/qnx/installing-qnx-on-raspberry-pi-4/
1. https://youtu.be/y42V_7ZTa-s

## Generate your own ifs-rpi4.bin

### Requirements
1. qnx710 env with bsp archive downloaded

see [Install QNX SW Center](#install-qnx-software-center) for how to download


### Generate environment
Extract the archive you want to work on in my example: BSP_raspberrypi-bcm2711-rpi4_br-710_be-710_SVN946248_JBN18.zip
```
export QNX_ROOT_DIR=~/qnx710    # default but may varie
export BSP_ROOT_DIR=$QNX_ROOT_DIR/bsp/BSP_raspberrypi-bcm2711-rpi4_br-710_be-710_SVN946248_JBN18  # default for rpi4 but may varie
```

```
cd $QNX_ROOT_DIR
source qnxsdp-env.sh
cd $BSP_ROOT_DIR && make
```
now the file $BSP_ROOT_DIR/images/ifs-rpi4.bin has been generated new

### Generate appropriate sd-card

The ifs file are read only file

#### On Ubuntu or windows system

I used the Ubuntu Disk utility to generate 2 fat partitions
```
Partition 0 : fat32 - 127 MB
Partition 1 : fat32 - Rest of the SD-Card
```

Copy the out folder after executing the script `generate-sd-card.bash`

#### On QNX target
After first boot on the QNX System
```
ls /dev/sd*     # check the partitions are all there

--- look like this for me
# ls /dev/sd*
/dev/sd0           /dev/sd1t12
/dev/sd1           /dev/sd1t12.1

--- to be sure what partition is big 
# df -h -P
Filesystem                  Size      Used Available Capacity  Mounted on      
/dev/sd1t12.1                15G      483M       14G       4%  /               
ifs                          30M       30M         0     100%  /               
/dev/sd1                    122M      122M         0     100%  /dev/sd1t12     
/dev/sd1                     15G       15G         0     100%                  
/dev/sd0                     15G       15G         0     100%  
```

So for me I need to mount /dev/sd1t12.1
Let us format the fat partition to qnx6
```
mkqnx6fs /dev/sd1t12.1
mount -t qnx6 /dev/sd1t12.1 /

# generate a few useful folders
mkdir -p /home/qnxuser
chown qnxuser:qnxuser /home/qnxuser

# restart qnx target
shutdown
```

source [QNXGuide from LinuxLink](https://linuxlink.timesys.com/docs/bfc/QNXGuide)

### Activate SSH

Mostly inspired from [qnx 7.1 doc](https://www.qnx.com/developers/docs/7.1/#com.qnx.doc.neutrino.utilities/topic/s/ssh.html)


### Activate AccessPoint


```
QNX® SDP 7.1 Wireless driver for the Broadcom BCM4339 (wpa-2.9)
QNX® SDP 7.1 Networking - io-sock Stable (7.1 BuildID 1952) 
QNX® SDP 7.1 Networking - WPA/WPA2/IEEE 802.1X Supplicant for use with io-sock Stable (7.1 BuildID 1227)
QNX® SDP 7.1 Networking - io-sock OpenSSH Stable (7.1 BuildID 1485)
      Release Notes: http://www.qnx.com/developers/articles/rel_6958_0.html

```