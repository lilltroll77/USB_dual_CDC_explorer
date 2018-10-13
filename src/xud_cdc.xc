// Copyright (c) 2016, XMOS Ltd, All rights reserved

#include <xs1.h>
#include <stdio.h>
#include <string.h>
#include "usb.h"
#include "xud_cdc.h"


#define UPDATE 0
/* USB CDC device product defines */
#define BCD_DEVICE  0x0100
#define VENDOR_ID   0x20B0
#define PRODUCT_ID  (0x0400 + N_CDC)

//Interface Association Descriptor
#define USB_IAD 0x0B

/* USB Sub class and protocol codes */
#define USB_CDC_ACM_SUBCLASS        0x02
#define USB_CDC_AT_COMMAND_PROTOCOL 0x01

/* CDC interface descriptor type */
#define USB_DESCTYPE_CS_INTERFACE   0x24



/* Data endpoint packet size */
#define MAX_EP_SIZE     4096

/* CDC Communications Class requests */
#define CDC_SET_LINE_CODING         0x20
#define CDC_GET_LINE_CODING         0x21
#define CDC_SET_CONTROL_LINE_STATE  0x22
#define CDC_SEND_BREAK              0x23

/* Definition of Descriptors */
/* USB Device Descriptor */

static unsigned char devDesc[] =
{
    0x12,                  /* 0  bLength */
    USB_DESCTYPE_DEVICE,   /* 1  bdescriptorType - Device*/
    0x00,                  /* 2  bcdUSB version */
    0x02,                  /* 3  bcdUSB version */
    0xEF,                  /* 4  bDeviceClass IAD*/
    0x02,                  /* 5  bDeviceSubClass  -   IAD  */
    0x01,                  /* 6  bDeviceProtocol  -   IAD  */
    0x40,                  /* 7  bMaxPacketSize for EP0 - max = 64*/
    (VENDOR_ID & 0xFF),    /* 8  idVendor */
    (VENDOR_ID >> 8),      /* 9  idVendor */
    (PRODUCT_ID & 0xFF),   /* 10 idProduct */
    (PRODUCT_ID >> 8),     /* 11 idProduct */
    (BCD_DEVICE & 0xFF),   /* 12 bcdDevice */
    (BCD_DEVICE >> 8),     /* 13 bcdDevice */
    0x01,                  /* 14 iManufacturer - index of string*/
    0x02,                  /* 15 iProduct  - index of string*/
    0x03,                  /* 16 iSerialNumber  - index of string*/
    0x01                   /* 17 bNumConfigurations */
};



static unsigned char IAD[]={
        //Interface Association Descriptor1
          0x08,                         //bLength
          USB_IAD,                      // bDescriptorType
          UPDATE,                       // BYTE  bFirstInterface !!UPDATE@2!!
          0x02,                         //bInterfaceCount
          USB_CLASS_COMMUNICATIONS,     // bFunctionClass
          USB_CDC_ACM_SUBCLASS,         // bFunctionSubClass
          USB_CDC_AT_COMMAND_PROTOCOL,   //bFunctionProtocol
          0x00                           // Interface string index
};

static unsigned char CDC[]={
        /* CDC Communication interface */
           0x09,                       /* 0  bLength */
           USB_DESCTYPE_INTERFACE,     /* 1  bDescriptorType - Interface */
           UPDATE ,                    /* 2  bInterfaceNumber - Interface 0 */ //!!UPDATE@2!!
           0x00,                       /* 3  bAlternateSetting */
           0x01,                       /* 4  bNumEndpoints */
           USB_CLASS_COMMUNICATIONS,   /* 5  bInterfaceClass */
           USB_CDC_ACM_SUBCLASS,       /* 6  bInterfaceSubClass - Abstract Control Model */
           USB_CDC_AT_COMMAND_PROTOCOL,/* 7  bInterfaceProtocol - AT Command V.250 protocol */
           0x00,                       /* 8  iInterface - No string descriptor */

           /* Header Functional descriptor */
 /*9*/     0x05,                      /* 0  bLength */
           USB_DESCTYPE_CS_INTERFACE, /* 1  bDescriptortype, CS_INTERFACE */
           0x00,                      /* 2  bDescriptorsubtype, HEADER */
           0x10, 0x01,                /* 3  bcdCDC */

           /* ACM Functional descriptor */
/*14*/     0x04,                      /* 0  bLength */
           USB_DESCTYPE_CS_INTERFACE, /* 1  bDescriptortype, CS_INTERFACE */
           0x02,                      /* 2  bDescriptorsubtype, ABSTRACT CONTROL MANAGEMENT */
           0x02,                      /* 3  bmCapabilities: Supports subset of ACM commands */

           /* Union Functional descriptor */
/*18*/     0x05,                     /* 0  bLength */
           USB_DESCTYPE_CS_INTERFACE,/* 1  bDescriptortype, CS_INTERFACE */
           0x06,                     /* 2  bDescriptorsubtype, UNION */
           UPDATE ,                  /* 3  bControlInterface - Interface 2 */  //!!UPDATE@21!!
           UPDATE ,                  /* 4  bSubordinateInterface0 - Interface 3 */ //!!UPDATE@22!!

           /* Call Management Functional descriptor */
/*23*/     0x05,                     /* 0  bLength */
           USB_DESCTYPE_CS_INTERFACE,/* 1  bDescriptortype, CS_INTERFACE */
           0x01,                     /* 2  bDescriptorsubtype, CALL MANAGEMENT */
           0x03,                     /* 3  bmCapabilities, DIY */
           UPDATE               ,      /* 4  bDataInterface */

           /* Notification Endpoint descriptor */
/*28*/     0x07,                         /* 0  bLength */
           USB_DESCTYPE_ENDPOINT,        /* 1  bDescriptorType */
           (UPDATE | 0x80),              /* 2  bEndpointAddress */ //!!UPDATE@30!!
           0x03,                         /* 3  bmAttributes */
           0x40,                         /* 4  wMaxPacketSize - Low */
           0x00,                         /* 5  wMaxPacketSize - High */
           0xFF,                         /* 6  bInterval */

           /* CDC Data interface */
/*35*/     0x09,                     /* 0  bLength */
           USB_DESCTYPE_INTERFACE,   /* 1  bDescriptorType */
           UPDATE ,                  /* 2  bInterfacecNumber */ //!!UPDATE@37!!
           0x00,                     /* 3  bAlternateSetting */
           0x02,                     /* 4  bNumEndpoints */
           USB_CLASS_CDC_DATA,       /* 5  bInterfaceClass */
           0x00,                     /* 6  bInterfaceSubClass */
           0x00,                     /* 7  bInterfaceProtocol*/
           0x00,                     /* 8  iInterface - No string descriptor*/

           /* Data OUT Endpoint descriptor */
/*44*/     0x07,                     /* 0  bLength */
           USB_DESCTYPE_ENDPOINT,    /* 1  bDescriptorType */
           UPDATE ,                  /* 2  bEndpointAddress */ //!!UPDATE@46!!
           0x02,                     /* 3  bmAttributes */
           0x00,                     /* 4  wMaxPacketSize - Low */
           0x02,                     /* 5  wMaxPacketSize - High */
           0x00,                     /* 6  bInterval */

           /* Data IN Endpoint descriptor */
/*51*/     0x07,                     /* 0  bLength */
           USB_DESCTYPE_ENDPOINT,    /* 1  bDescriptorType */
           (UPDATE  | 0x80),            /* 2  bEndpointAddress */ //!!UPDATE@53!!
           0x02,                     /* 3  bmAttributes */
           0x00,                     /* 4  wMaxPacketSize - Low byte */
           0x02,                     /* 5  wMaxPacketSize - High byte */
           0x01                      /* 6  bInterval */
};


#define CFG_LEN (9 + N_CDC*(sizeof(IAD) + sizeof(CDC)))
static unsigned char cfgDesc[CFG_LEN]={
        0x09,                       /* 0  bLength */
        USB_DESCTYPE_CONFIGURATION, /* 1  bDescriptortype - Configuration*/
        (CFG_LEN & 0xFF), CFG_LEN>>8,  /* 2  wTotalLength */
        2*N_CDC,                       /* 4  bNumInterfaces */
        0x01,                       /* 5  bConfigurationValue */
        0x00,                       /* 6  iConfiguration - index of string */
        0x80,                       /* 7  bmAttributes - Bus powered */
        0xC8,                       /* 8  bMaxPower - 400mA */
};




struct type_t{
    unsigned char notification;
    unsigned char rx;
    unsigned char tx;
    unsigned char data;
};

struct CDC_t{
    struct type_t intf;
    struct type_t EP;
};

unsafe unsigned char* unsafe writeIAD(unsigned char* unsafe ptr , unsigned char intf){
    memcpy(ptr , IAD , sizeof(IAD));
    ptr[2]=intf; //bFirstInterface
    return ptr+sizeof(IAD);
}

unsafe unsigned char* unsafe writeCDC(unsigned char* unsafe ptr , struct CDC_t cdc){
    memcpy(ptr , CDC , sizeof(CDC));
    ptr[2]= cdc.intf.notification;
    ptr[21]=cdc.intf.notification;
    ptr[22]=cdc.intf.data;
    ptr[27]=cdc.intf.data;
    ptr[30]=cdc.EP.notification| 0x80;
    ptr[37]=cdc.intf.data;
    ptr[46]=cdc.EP.rx;
    ptr[53]=cdc.EP.tx | 0x80;
    return ptr+sizeof(CDC);

    /* CDC Communication interface */


}




unsafe{
  /* String table - unsafe as accessed via shared memory */
  static char * unsafe stringDescriptors[]=
  {
    "\x09\x04",             /* Language ID string (US English) */
    "XMOS",                 /* iManufacturer */
    "CDC Virtual COM Port", /* iProduct */
    "0123456789"            /* iSerialNumber */
    "Config",               /* iConfiguration string */
  };
}

/* CDC Class-specific requests handler function */
XUD_Result_t ControlInterfaceClassRequests(XUD_ep ep_out, XUD_ep ep_in, USB_SetupPacket_t sp)
{
    /* Word aligned buffer */
    unsigned int buffer[32];
    unsigned length;
    XUD_Result_t result;

    static struct LineCoding {
        unsigned int baudRate;
        unsigned char charFormat;
        unsigned char parityType;
        unsigned char dataBits;
    }lineCoding;

    static struct lineState {
        unsigned char dtr;
        unsigned char rts;
    } lineState;

#if defined (DEBUG) && (DEBUG == 1)
    printhexln(sp.bRequest);
#endif

    switch(sp.bRequest)
    {
        case CDC_SET_LINE_CODING:

            if((result = XUD_GetBuffer(ep_out, (buffer, unsigned char[]), length)) != XUD_RES_OKAY)
            {
                return result;
            }

            lineCoding.baudRate = buffer[0];    /* Read 32-bit baud rate value */
            lineCoding.charFormat = (buffer, unsigned char[])[4]; /* Read one byte */
            lineCoding.parityType = (buffer, unsigned char[])[5];
            lineCoding.dataBits = (buffer, unsigned char[])[6];

            result = XUD_DoSetRequestStatus(ep_in);

            #if defined (DEBUG) && (DEBUG == 1)
            printf("Baud rate: %u\n", lineCoding.baudRate);
            printf("Char format: %d\n", lineCoding.charFormat);
            printf("Parity Type: %d\n", lineCoding.parityType);
            printf("Data bits: %d\n", lineCoding.dataBits);
            #endif
            return result;

            break;

        case CDC_GET_LINE_CODING:

            buffer[0] = lineCoding.baudRate;
            (buffer, unsigned char[])[4] = lineCoding.charFormat;
            (buffer, unsigned char[])[5] = lineCoding.parityType;
            (buffer, unsigned char[])[6] = lineCoding.dataBits;

            return XUD_DoGetRequest(ep_out, ep_in, (buffer, unsigned char[]), 7, sp.wLength);

            break;

        case CDC_SET_CONTROL_LINE_STATE:

            /* Data present in wValue */
            lineState.dtr = sp.wValue & 0x01;
            lineState.rts = (sp.wValue >> 1) & 0x01;

            /* Acknowledge */
            result =  XUD_DoSetRequestStatus(ep_in);

            #if defined (DEBUG) && (DEBUG == 1)
            printf("DTR: %d\n", lineState.dtr);
            printf("RTS: %d\n", lineState.rts);
            #endif

            return result;

            break;

        case CDC_SEND_BREAK:
            /* Send break signal on UART (if requried) */
            // sp.wValue says the number of milliseconds to hold in BREAK condition
            return XUD_DoSetRequestStatus(ep_in);

            break;

        default:
            // Error case
            printstr("Unknown ControlInterfaceClassRequests");
            printhexln(sp.bRequest);
            break;
    }
    return XUD_RES_ERR;
}
#if(DEBUG)
static unsigned char cfgDesc_ref[] = {

  0x09,                       /* 0  bLength */
  USB_DESCTYPE_CONFIGURATION, /* 1  bDescriptortype - Configuration*/
  CFG_LEN, 0x00,                 /* 2  wTotalLength */
  0x04,//!!                   /* 4  bNumInterfaces */ //!!
  0x01,                       /* 5  bConfigurationValue */
  0x00,                       /* 6  iConfiguration - index of string */
  0x80,                       /* 7  bmAttributes - Bus powered */
  0xC8,                       /* 8  bMaxPower - 400mA */

  //Interface Association Descriptor1
  0x08,                         //bLength
  USB_IAD,                      //  bDescriptorType
  CDC_NOTIFICATION_INTERFACE1,  // BYTE  bFirstInterface
  0x02,  //!!                       //bInterfaceCount
  USB_CLASS_COMMUNICATIONS,     // bFunctionClass
  USB_CDC_ACM_SUBCLASS,         // bFunctionSubClass
  USB_CDC_AT_COMMAND_PROTOCOL,   //bFunctionProtocol
  0x00,                           // Interface string index

  /* CDC Communication interface */
  0x09,                       /* 0  bLength */
  USB_DESCTYPE_INTERFACE,     /* 1  bDescriptorType - Interface */
  CDC_NOTIFICATION_INTERFACE1,/* 2  bInterfaceNumber - Interface 0 */
  0x00,                       /* 3  bAlternateSetting */
  0x01,                       /* 4  bNumEndpoints */
  USB_CLASS_COMMUNICATIONS,   /* 5  bInterfaceClass */
  USB_CDC_ACM_SUBCLASS,       /* 6  bInterfaceSubClass - Abstract Control Model */
  USB_CDC_AT_COMMAND_PROTOCOL,/* 7  bInterfaceProtocol - AT Command V.250 protocol */
  0x00,                       /* 8  iInterface - No string descriptor */

  /* Header Functional descriptor */
  0x05,                      /* 0  bLength */
  USB_DESCTYPE_CS_INTERFACE, /* 1  bDescriptortype, CS_INTERFACE */
  0x00,                      /* 2  bDescriptorsubtype, HEADER */
  0x10, 0x01,                /* 3  bcdCDC */

  /* ACM Functional descriptor */
  0x04,                      /* 0  bLength */
  USB_DESCTYPE_CS_INTERFACE, /* 1  bDescriptortype, CS_INTERFACE */
  0x02,                      /* 2  bDescriptorsubtype, ABSTRACT CONTROL MANAGEMENT */
  0x02,                      /* 3  bmCapabilities: Supports subset of ACM commands */

  /* Union Functional descriptor */
  0x05,                     /* 0  bLength */
  USB_DESCTYPE_CS_INTERFACE,/* 1  bDescriptortype, CS_INTERFACE */
  0x06,                     /* 2  bDescriptorsubtype, UNION */
  CDC_NOTIFICATION_INTERFACE1,/* 3  bControlInterface - Interface 0 */
  CDC_DATA_INTERFACE1,        /* 4  bSubordinateInterface0 - Interface 1 */

  /* Call Management Functional descriptor */
  0x05,                     /* 0  bLength */
  USB_DESCTYPE_CS_INTERFACE,/* 1  bDescriptortype, CS_INTERFACE */
  0x01,                     /* 2  bDescriptorsubtype, CALL MANAGEMENT */
  0x03,                     /* 3  bmCapabilities, DIY */
  0x01,                     /* 4  bDataInterface */

  /* Notification Endpoint descriptor */
  0x07,                         /* 0  bLength */
  USB_DESCTYPE_ENDPOINT,        /* 1  bDescriptorType */
  (CDC_NOTIFICATION_EP_NUM1 | 0x80),/* 2  bEndpointAddress */
  0x03,                         /* 3  bmAttributes */
  0x40,                         /* 4  wMaxPacketSize - Low */
  0x00,                         /* 5  wMaxPacketSize - High */
  0xFF,                         /* 6  bInterval */


  /* CDC Data interface */
  0x09,                     /* 0  bLength */
  USB_DESCTYPE_INTERFACE,   /* 1  bDescriptorType */
  CDC_DATA_INTERFACE1,      /* 2  bInterfacecNumber */
  0x00,                     /* 3  bAlternateSetting */
  0x02,                     /* 4  bNumEndpoints */
  USB_CLASS_CDC_DATA,       /* 5  bInterfaceClass */
  0x00,                     /* 6  bInterfaceSubClass */
  0x00,                     /* 7  bInterfaceProtocol*/
  0x00,                     /* 8  iInterface - No string descriptor*/

  /* Data OUT Endpoint descriptor */
  0x07,                     /* 0  bLength */
  USB_DESCTYPE_ENDPOINT,    /* 1  bDescriptorType */
  CDC_DATA_RX_EP_NUM1,       /* 2  bEndpointAddress */
  0x02,                     /* 3  bmAttributes */
  0x00,                     /* 4  wMaxPacketSize - Low */
  0x02,                     /* 5  wMaxPacketSize - High */
  0x00,                     /* 6  bInterval */

  /* Data IN Endpoint descriptor */
  0x07,                     /* 0  bLength */
  USB_DESCTYPE_ENDPOINT,    /* 1  bDescriptorType */
  (CDC_DATA_TX_EP_NUM1 | 0x80),/* 2  bEndpointAddress */
  0x02,                     /* 3  bmAttributes */
  0x00,                     /* 4  wMaxPacketSize - Low byte */
  0x02,                     /* 5  wMaxPacketSize - High byte */
  0x01,                      /* 6  bInterval */




  //Interface Association Descriptor1
  0x08,                         //bLength
  USB_IAD,                      //  bDescriptorType
  CDC_NOTIFICATION_INTERFACE2,  // BYTE  bFirstInterface
  0x02,                         //bInterfaceCount
  USB_CLASS_COMMUNICATIONS,     // bFunctionClass
  USB_CDC_ACM_SUBCLASS,         // bFunctionSubClass
  USB_CDC_AT_COMMAND_PROTOCOL,   //bFunctionProtocol
  0x00,                           // Interface string index

  /* CDC Communication interface */
   0x09,                       /* 0  bLength */
   USB_DESCTYPE_INTERFACE,     /* 1  bDescriptorType - Interface */
   CDC_NOTIFICATION_INTERFACE2,/* 2  bInterfaceNumber - Interface 0 */
   0x00,                       /* 3  bAlternateSetting */
   0x01,                       /* 4  bNumEndpoints */
   USB_CLASS_COMMUNICATIONS,   /* 5  bInterfaceClass */
   USB_CDC_ACM_SUBCLASS,       /* 6  bInterfaceSubClass - Abstract Control Model */
   USB_CDC_AT_COMMAND_PROTOCOL,/* 7  bInterfaceProtocol - AT Command V.250 protocol */
   0x00,                       /* 8  iInterface - No string descriptor */

   /* Header Functional descriptor */
   0x05,                      /* 0  bLength */
   USB_DESCTYPE_CS_INTERFACE, /* 1  bDescriptortype, CS_INTERFACE */
   0x00,                      /* 2  bDescriptorsubtype, HEADER */
   0x10, 0x01,                /* 3  bcdCDC */

   /* ACM Functional descriptor */
   0x04,                      /* 0  bLength */
   USB_DESCTYPE_CS_INTERFACE, /* 1  bDescriptortype, CS_INTERFACE */
   0x02,                      /* 2  bDescriptorsubtype, ABSTRACT CONTROL MANAGEMENT */
   0x02,                      /* 3  bmCapabilities: Supports subset of ACM commands */

   /* Union Functional descriptor */
   0x05,                     /* 0  bLength */
   USB_DESCTYPE_CS_INTERFACE,/* 1  bDescriptortype, CS_INTERFACE */
   0x06,                     /* 2  bDescriptorsubtype, UNION */
   CDC_NOTIFICATION_INTERFACE2,/* 3  bControlInterface - Interface 2 */
   CDC_DATA_INTERFACE2,        /* 4  bSubordinateInterface0 - Interface 3 */

   /* Call Management Functional descriptor */
   0x05,                     /* 0  bLength */
   USB_DESCTYPE_CS_INTERFACE,/* 1  bDescriptortype, CS_INTERFACE */
   0x01,                     /* 2  bDescriptorsubtype, CALL MANAGEMENT */
   0x03,                     /* 3  bmCapabilities, DIY */
   0x03,                     /* 4  bDataInterface */

   /* Notification Endpoint descriptor */
   0x07,                         /* 0  bLength */
   USB_DESCTYPE_ENDPOINT,        /* 1  bDescriptorType */
   (CDC_NOTIFICATION_EP_NUM2 | 0x80),/* 2  bEndpointAddress */
   0x03,                         /* 3  bmAttributes */
   0x40,                         /* 4  wMaxPacketSize - Low */
   0x00,                         /* 5  wMaxPacketSize - High */
   0xFF,                         /* 6  bInterval */

   /* CDC Data interface */
   0x09,                     /* 0  bLength */
   USB_DESCTYPE_INTERFACE,   /* 1  bDescriptorType */
   CDC_DATA_INTERFACE2,      /* 2  bInterfacecNumber */
   0x00,                     /* 3  bAlternateSetting */
   0x02,                     /* 4  bNumEndpoints */
   USB_CLASS_CDC_DATA,       /* 5  bInterfaceClass */
   0x00,                     /* 6  bInterfaceSubClass */
   0x00,                     /* 7  bInterfaceProtocol*/
   0x00,                     /* 8  iInterface - No string descriptor*/

   /* Data OUT Endpoint descriptor */
   0x07,                     /* 0  bLength */
   USB_DESCTYPE_ENDPOINT,    /* 1  bDescriptorType */
   CDC_DATA_RX_EP_NUM2,       /* 2  bEndpointAddress */
   0x02,                     /* 3  bmAttributes */
   0x00,                     /* 4  wMaxPacketSize - Low */
   0x02,                     /* 5  wMaxPacketSize - High */
   0x00,                     /* 6  bInterval */

   /* Data IN Endpoint descriptor */
   0x07,                     /* 0  bLength */
   USB_DESCTYPE_ENDPOINT,    /* 1  bDescriptorType */
   (CDC_DATA_TX_EP_NUM2 | 0x80),/* 2  bEndpointAddress */
   0x02,                     /* 3  bmAttributes */
   0x00,                     /* 4  wMaxPacketSize - Low byte */
   0x02,                     /* 5  wMaxPacketSize - High byte */
   0x01                      /* 6  bInterval */
};
#endif


/* Endpoint 0 handling both std USB requests and CDC class specific requests */
void Endpoint0(chanend chan_ep0_out, chanend chan_ep0_in)
{
    struct CDC_t cdc;
    unsafe{
        //cfgDesc[4]=2*N_CDC;
    unsigned char* unsafe ptr = &cfgDesc[9];
    for(int i=0; i<N_CDC ; i++){
        cdc.intf.notification=  2*i;
        cdc.intf.data =         cdc.intf.notification+1;
        cdc.EP.notification =   cdc.intf.notification+1;
        cdc.EP.rx = i+1;
        cdc.EP.tx = cdc.EP.notification+1;
        ptr = writeIAD(ptr , cdc.intf.notification);
        ptr = writeCDC(ptr , cdc);
    }
    }

#if(DEBUG)
    for(int i=0 ; i<sizeof(cfgDesc_ref) ; i++)
        if(cfgDesc_ref[i] != cfgDesc[i]){
            int m=i-9 - sizeof(IAD);
            printint(m);
            printchar('(');
            printuint(cfgDesc_ref[i]);
            printchar(',');
            printuint(cfgDesc[i]);
            printchar(')');
            printstr(" ERROR!");
            printcharln(' ');
        }
#endif

    USB_SetupPacket_t sp;

    unsigned bmRequestType;
    XUD_BusSpeed_t usbBusSpeed;

    XUD_ep ep0_out = XUD_InitEp(chan_ep0_out, XUD_EPTYPE_CTL | XUD_STATUS_ENABLE);
    XUD_ep ep0_in = XUD_InitEp(chan_ep0_in, XUD_EPTYPE_CTL | XUD_STATUS_ENABLE);

    while(1)
    {
        /* Returns XUD_RES_OKAY on success */
        XUD_Result_t result = USB_GetSetupPacket(ep0_out, ep0_in, sp);

        if(result == XUD_RES_OKAY)
        {
            /* Set result to ERR, we expect it to get set to OKAY if a request is handled */
            result = XUD_RES_ERR;

            /* Stick bmRequest type back together for an easier parse... */
            bmRequestType = (sp.bmRequestType.Direction<<7) |
                            (sp.bmRequestType.Type<<5) |
                            (sp.bmRequestType.Recipient);

            if ((bmRequestType == USB_BMREQ_H2D_STANDARD_DEV) &&
                (sp.bRequest == USB_SET_ADDRESS))
            {
              // Host has set device address, value contained in sp.wValue
            }

            switch(bmRequestType)
            {
                /* Direction: Device-to-host and Host-to-device
                 * Type: Class
                 * Recipient: Interface
                 */
                case USB_BMREQ_H2D_CLASS_INT:
                case USB_BMREQ_D2H_CLASS_INT:
                    /* Inspect for CDC Communications Class interface num */

                    if( (sp.wIndex &1) == 0) // even numbers , odd is data
                    {
                        /* Returns  XUD_RES_OKAY if handled,
                         *          XUD_RES_ERR if not handled,
                         *          XUD_RES_RST for bus reset */
                        result = ControlInterfaceClassRequests(ep0_out, ep0_in, sp);
                    }
                    else{
                        printstr("USB Interface error in endpoint 0");
                        printintln(sp.wIndex);
                    }
                    break;
            }
        } /* if ends */

        /* If we haven't handled the request about then do standard enumeration requests */
        if(result == XUD_RES_ERR )
        {
            /* Returns  XUD_RES_OKAY if handled okay,
             *          XUD_RES_ERR if request was not handled (STALLed),
             *          XUD_RES_RST for USB Reset */
            unsafe{
            result = USB_StandardRequests(ep0_out, ep0_in, devDesc,
                        sizeof(devDesc), cfgDesc, sizeof(cfgDesc),
                        null, 0, null, 0, stringDescriptors, sizeof(stringDescriptors)/sizeof(stringDescriptors[0]),
                        sp, usbBusSpeed);
             }
        }

        /* USB bus reset detected, reset EP and get new bus speed */
        if(result == XUD_RES_RST)
        {
            usbBusSpeed = XUD_ResetEndpoint(ep0_out, ep0_in);
        }
    }
}

/* Function to handle all endpoints of the CDC class excluding control endpoint0 */
void CdcEndpointsHandler(chanend c_epint_in, chanend c_epbulk_out, chanend c_epbulk_in
                         /*,SERVER_INTERFACE(usb_cdc_interface, cdc)*/)
{
    /*static*/ unsigned char txBuf[2][MAX_EP_SIZE];
    /*static*/ unsigned char rxBuf[2][MAX_EP_SIZE];
    int readBufId = 0, writeBufId = 0;          // used to identify buffer read/write by device
    int rxLen[2] = {0, 0}, txLen = 0;
    int readIndex = 0;
    int readWaiting = 0, writeWaiting = 1;

    unsigned length;
    XUD_Result_t result;

    /* Initialize all endpoints */
    XUD_ep epint_in = XUD_InitEp(c_epint_in, XUD_EPTYPE_INT);
    XUD_ep epbulk_out = XUD_InitEp(c_epbulk_out, XUD_EPTYPE_BUL);
    XUD_ep epbulk_in = XUD_InitEp(c_epbulk_in, XUD_EPTYPE_BUL);

    /* XUD will NAK if the endpoint is not ready to communicate with XUD */

    /* TODO: Interrupt endpoint to report serial state (if required) */

    /* Just to keep compiler happy */
    epint_in = epint_in;

    XUD_SetReady_Out(epbulk_out, rxBuf[!readBufId]);

    while(1)
    {
      select
      {
        case XUD_GetData_Select(c_epbulk_out, epbulk_out, length, result):

           if(result == XUD_RES_OKAY)
           {
               /* Received some data */
               rxLen[!readBufId] = length;

               /* Check if application has completed reading the read buffer */
               if(rxLen[readBufId] == 0) {
                   /* Switch buffers */
                   readBufId = !readBufId;
                   readIndex = 0;
                   /* Make the OUT endpoint ready to receive data */
                   XUD_SetReady_Out(epbulk_out, rxBuf[!readBufId]);
               } else {
                   /* Application is still reading the read buffer
                    * Say that another buffer is also waiting to be read */
                   readWaiting = 1;
               }
               //cdc.data_ready();
           } else {
               XUD_SetReady_Out(epbulk_out, rxBuf[!readBufId]);
           }
           break;

        case XUD_SetData_Select(c_epbulk_in, epbulk_in, result):

            /* Packet sent successfully when result in XUD_RES_OKAY */
            if (0 != txLen) {
                /* Data available to send to Host */
                XUD_SetReady_In(epbulk_in, txBuf[writeBufId], txLen);
                /* Switch write buffers */
                writeBufId = !writeBufId;
                txLen = 0;
            } else {
                writeWaiting = 1;
            }

            break;
        default:
            int count = rxLen[readBufId];
            if(count != rxLen[readBufId]){
                // process data here
            }
            break;
        } // select
    }
}
