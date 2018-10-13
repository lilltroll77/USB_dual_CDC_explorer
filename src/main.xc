// Copyright (c) 2016, XMOS Ltd, All rights reserved

#include <platform.h>
#include <xs1.h>
#include "usb.h"
#include "xud_cdc.h"
//#include "app_virtual_com_extended.h"

// I2C interface ports
//on tile[0]: port p_scl = XS1_PORT_1E;
//on tile[0]: port p_sda = XS1_PORT_1F;

/* USB Endpoint Defines */
#define XUD_EP_COUNT_OUT    (1+N_CDC)    //Includes EP0 (1 OUT EP0 + 2 BULK OUT EP)
#define XUD_EP_COUNT_IN     (1+2*N_CDC)  //Includes EP0 (1 IN EP0 + 2 INTERRUPT IN EP + 2 BULK IN EP)

int main(){
    /* Channels to communicate with USB endpoints */
    chan c_ep_out[XUD_EP_COUNT_OUT], c_ep_in[XUD_EP_COUNT_IN];
    /* Interface to communicate with USB CDC (Virtual Serial) */
    //interface usb_cdc_interface cdc_data[N_CDC];
    /* I2C interface */


    par
        {
            on USB_TILE: xud(c_ep_out, XUD_EP_COUNT_OUT, c_ep_in, XUD_EP_COUNT_IN,
                    null, XUD_SPEED_HS, XUD_PWR_SELF);

            on USB_TILE: Endpoint0(c_ep_out[0], c_ep_in[0]);

            on tile[0]: par(int i=0; i<N_CDC ; i++)
                 CdcEndpointsHandler(c_ep_in[2*i+1], c_ep_out[i+1], c_ep_in[2*i+2]);
         }

    return 0;
}
