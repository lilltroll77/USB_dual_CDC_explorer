USB CDC Class as Virtual Serial Port - Extended on xCORE-200 Explorer
=====================================================================

.. version:: 1.0.2

Summary
-------

This application note shows how to create a USB device compliant to
the standard USB Communications Device Class (CDC) on an XMOS multicore microcontroller.

The code associated with this application note provides an example of
using the XMOS USB Device Library (XUD) and associated USB class descriptors
to provide a framework for the creation of a USB CDC device that implements
Abstract Control Model (ACM).

This example USB CDC ACM implementation provides a Virtual Serial port
running over high speed USB. The Virtual Serial port supports the 
standard requests associated with ACM model of the class.

A serial terminal program from host PC connects to virtual serial port and
interacts with the application. The application provides a menu to toggle
on-board LEDs, read an I2C device, monitor buttons and loopback characters.
This application demo code demonstrates a simple way in which USB CDC class
devices can easily be deployed using an xCORE-200 device.

Note: This application note provides a standard USB CDC class device and as a 
result does not require external drivers to run on Windows, Mac or Linux.

This application note extends AN00124 to provide a virtual serial port
application that interfaces to hardware demostrating how to build a system
which allows a USB host to connect to custom hardware using an XMOS device.

Required tools and libraries
............................

* xTIMEcomposer Tools - Version 14.0.0
* XMOS USB library - Version 3.1.0
* XMOS I2C library - Version 2.0.0

Required hardware
.................

This application note is designed to run on an XMOS xCORE-200 series device.

The example code provided with the application has been implemented and tested
on the xCORE-200 explorerKIT but there is no dependancy on this board 
and it can be modified to run on any development board which uses an xCORE-USB series device.

Prerequisites
.............

  - This document assumes familiarity with the XMOS xCORE architecture, the Universal Serial Bus 2.0 Specification and related specifications, the XMOS tool chain and the xC language. Documentation related to these aspects which are not specific to this application note are linked to in the references appendix.

  - For descriptions of XMOS related terms found in this document please see the XMOS Glossary [#]_.

  - For the full API listing of the XMOS USB Device (XUD) Library please see the document XMOS USB Device (XUD) Library [#]_.

  - For information on designing USB devices using the XUD library please see the XMOS USB Device Design Guide for reference [#]_.

  - For information on the USB CDC class using the XMOS USB library see AN00124

  - For information on using the xCORE-200 explorerKIT accelerometer see AN00181

  .. [#] http://www.xmos.com/published/glossary

  .. [#] http://www.xmos.com/published/xuddg

  .. [#] http://www.xmos.com/published/xmos-usb-device-design-guide