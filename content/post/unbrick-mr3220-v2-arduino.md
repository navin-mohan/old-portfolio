---
title: "Unbricking TP-LINK MR3220 V2 using Arduino"
date: 2014-08-05T18:41:00Z
---

In this post I’ll be explaining how to unbrick tp-link wireless N router. This only works if the boot loader is not damaged. It worked for me and hope it will for you. I’m not responsible for any damaged device and do it at your own risk.

## Things You Will need

1. Male Berg Connectors
2. Soldering kit
3. Arduino (or any other USB to TTL converter should work)
4. Connecting wires
5. A PC or Mac(I use Windows Here as the the drivers are available easily)
6. Jumper Cables

## How-To

First to get to the board you need to remove the router’s case. Start with the antenna and then remove those screws(two of them) under the case.

![MR3220 - screws](https://1.bp.blogspot.com/-pXRyP1xAgRM/U-EDIEkM4SI/AAAAAAAAAE0/I6YwvZFRfn0/s1600/screws.JPG.png)

Now when you are done with the screws, remove the nut and washer from the antenna connector.

![MR3220 - antenna](https://4.bp.blogspot.com/-1iyrjcCEuOA/U-EIMQ6f3VI/AAAAAAAAAFE/fwycZqwXG5I/s1600/antenna+nut.png)

After doing that carefully try to push the antenna connector inside(just move it so that it will not be damaged while opening the case)  
 Now comes the tricky part, to unlock the push-in locks on the case. Start with the ones on the two corners at the back. After unlocking them use a pin or something to unlock the locks on either sides and finally do the same for the ones at the front. It takes a little time to get it right. Now when the top cover is removed we are almost there with the access to the board.

![MR3220 - main PCB](https://3.bp.blogspot.com/-PD0zvA-DBg8/U-EN71VUUzI/AAAAAAAAAFU/gpcatkARAcM/s1600/topopen.JPG)

After opening up the case, now completely push the antenna connector and other ports at the back of the router inside and take the board out. Here comes the area which demands  some skill. To connect the RX and TX pins.To be able to use UART you need to connect the TP18 to TP38 and TP28 to TP48. Look for these printed on the down side of the board. Find them and solder two wires shorting them as mentioned. Google for more on soldering.When done test the continuity with a multi-meter.

![MR3220 - TP18 and TP28](https://1.bp.blogspot.com/-bAYWNDqUPiQ/U-EUWWIqHzI/AAAAAAAAAFk/z4qsOFmlm0U/s1600/DSCF6435.JPG)

![MR3220 - solder](https://2.bp.blogspot.com/-A_7IecL5RTE/U-EUWaBZixI/AAAAAAAAAFo/QW8AZjfGTZI/s1600/DSCF6436.JPG)

Now after connecting those pins ,solder the male berg connectors in place (as shown) so that the UART connection can be made.

![MR3220 - TTL out](https://1.bp.blogspot.com/_WRAETRKJP_o/TPT0IIhgmdI/AAAAAAAAAB0/TV6o4iFsZ2Y/s1600/162558526.jpg)

When everything is set the router is ready to be unbricked.

#### SETTING UP THE ARDUINO

To convert the Arduino to our required USB to TTL converter we need to disable the mcu chip and use the on board FTDI chip. For this using a jumper cable connect the RESET pin on the Analogue side to the ground pin(GND). This will shift the mcu to Tristate mode. Now use those pins marked Tx and Rx(pin 0 and 1) on the Arduino to connect the Tx and Rx pins on the router board(use jumper cables). Don’t forget about the ground and remain the VCC pin free. Before connecting to the router the drivers for the FTDI chip should be installed on your PC and a few tools are required.

![MR3220 - arduino set up](https://3.bp.blogspot.com/-j-1s6l6jQDk/U-Ej5gMmAFI/AAAAAAAAAGI/qEYyLmWtEXU/s1600/DSCF6453.JPG)

![MR3220 - Arduino TTL](https://1.bp.blogspot.com/-qgLEzL3mVPo/U-Ej5WCqrvI/AAAAAAAAAGE/YM7ZMdBaMAI/s1600/DSCF6452.JPG)

![MR3220 - Arduino reset](https://3.bp.blogspot.com/-TQvvVYogMFM/U-Ej4W9JgCI/AAAAAAAAAF8/hu8FYOyKa1E/s1600/DSCF6451.JPG)

![MR3220 - complete setup](https://1.bp.blogspot.com/-D0Gy2WMBUnA/U-EkNQMPFPI/AAAAAAAAAGU/ow3cPoD5Rtc/s1600/DSCF6442.JPG)

#### Required Programs

- [Putty](http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html)
- [Open TFTP Server](https://sourceforge.net/projects/tftp-server/)
- [FTDI driver](http://www.ftdichip.com/FTDrivers.htm)

Install FTDI drivers and connect the the Arduino with the RESET and GND shorted. Let windows detect and configure the device. Now go to device manager and look for the communication ports and find the FTDI usb to ttl virtual COM port and note its number(like COM3).Run the tftp server and choose a root directory for it and place your openwrt firmware there(rename it to firm.bin or something so that it is easy to use).  
 Now power up your router and connect it to your PC using ethernet cable(RJ-45). Configure your PC’s NIC to the IP address 192.168.1.27. Then connect the Rx,Tx and GND of the router to the Arduino’s pins as mentioned before.  
 Run putty and choose the serial connection. Change the preferences to the following

```
Bits per second: 115200
Data bits: 8
Stop bits: 1 
Parity: None 
Flow control: None
```

Start a connection on your COM port(Arduino’s virtual COM port) using the COM port number. A console window will appear showing data coming from the router. You’ll see a line saying “Autobooting in 1s…”, when you see this quickly type in “tpl” to get access. If you see gibberish data on screen you might have connected the Rx or Tx pin the wrong way or gone wrong with the baud rate or something else is wrong. When you get access to the console you are almost there. Type in these commands when you have the console.  
*To program the new image:*

Erase the memory

```
> erase 0x9f020000 +0x3c0000  
```

Download the new firmware

```
> tftpboot 0x81000000 firm.bin 
```

Copy memory bytes into flash

```
> cp.b 0x81000000 0x9f020000 0x3c0000 
```

Boot kernel image from memory location

```
> bootm 0x9f020000
```

If everything went fine the router will reboot and will be reverted back to the openwrt firmware. Use telnet or ssh to access the router and flash back the original firmware.

#### Flashing back the original firmware

- use scp to transfer the original firmware to the /tmp directory on your router
- run these command while in the /tmp directory(original.bin is the original firmware for tl mr3220)
- dd if=orig.bin of=out.bin skip=257 bs=512
- mtd -r write out.bin firmware
- If successfully flashed back the firmware the router will reboot and everything will be as factory defaults. Use 192.168.1.1 to access the router settings.




