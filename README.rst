XMOS: Composite USB device with dual Virtual Serial Port
...........................................

This application shows how to create a composite USB device with dual Virtual Serial Ports compliant to
the standard USB Communications Device Class (CDC) on an XMOS multicore microcontroller.

It also shows how printf can be used without disrupting the USB and how core priority can be used to run:
5+3 worker cores running at 100MHz each (500MHz clock with a 5 stage pipeline)
1 USB core running at 100MHz
5 software threads (Endpoints , CDC  etc) running on 4 cores with help of [[combine]]
All 4 cores runs in low priority mode, sharing 100MHz.

A MATLAB script can be used to send messages on both COM ports wihout effecting the worker threads.
  

The USB Configuration Descriptor uses an Interface Association Descriptor to describe the 2 interfaces.

2 serial USB devices should enumerate in Win10.

2 terminals can be connected, one to each port.

Each COM port will write a header and then loopback the sent data.

Required tools and libraries
............................

* xTIMEcomposer Tools - Version 14.0.0 (minimum)
* XMOS USB library - Version 3.1.0 (minimum)

Required hardware
.................

This application is designed to run on an XMOS xCORE-200 series device.

The example code provided with the application has been implemented and tested
on the xCORE-200 explorerKIT with xTIMEcomposer ver. Community_14.3.2 running on Microsoft Windows 10 Home 64-bit [Version 10.0.17134.345]

Required settings
.................
Important: To run the code the "xSCOPE ( via xCONNECT/UART)" must be selected in Run Configuration. Otherwise the JTAG will disrupt realtime operation if anything is written to stdio (printf, print etc). 
Any call to stdio using JTAG mode instead of the xCONNECT mode will make the usb services to fail.
 ioMode="basic" is used in config.xscope.  ioMode="none" CAN NOT BE USED FOR REAL TIME

For Windows 8.1 and earlier versions
.....................................
In Windows 8.1 and earlier versions of the operating system, Usbser.sys is not automatically loaded when a USB-to-serial device is attached to a computer. To load the driver, you need to write an INF that references the modem INF (mdmcpq.inf) by using the Include directive. The directive is required for instantiating the service, copying inbox binaries, and registering a device interface GUID that applications require to find the device and talk to it. That INF specifies "Usbser" as a lower filter driver in a device stack.
https://docs.microsoft.com/en-us/windows-hardware/drivers/usbcon/usb-driver-installation-based-on-compatible-ids

Download XMOS Application Note AN00184_cdc_extended_explorer for a INF file example.
