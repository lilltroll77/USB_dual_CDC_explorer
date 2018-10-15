// Copyright (c) 2016, XMOS Ltd, All rights reserved

#include <platform.h>
#include <xs1.h>
#include "usb.h"
#include "xud_cdc.h"
#include "app_virtual_com_extended.h"
#include "stdio.h"
#include <xscope.h>

// I2C interface ports
on tile[0]: port p_scl = XS1_PORT_1E;
on tile[0]: port p_sda = XS1_PORT_1F;

/* USB Endpoint Defines */
#define XUD_EP_COUNT_OUT   3    //Includes EP0 (1 OUT EP0 + 2 BULK OUT EP)
#define XUD_EP_COUNT_IN    5    //Includes EP0 (1 IN EP0 + 2 INTERRUPT IN EP + 2 BULK IN EP)

#define ms 1e5


static inline
add(unsigned counter){
      counter++;
      counter++;
      counter++;
      counter++;
      counter++;
      counter++;
      counter++;
      counter++;
      counter++;
      counter++;
}

void worker(int Tile , int ID , unsigned delay){
    set_core_high_priority_on();
    timer tmr;
    unsigned checksum=1;
    unsigned poly =0xFFFFFFFF;
    unsigned counter=0;
    unsigned t , t_new;
    const int l=10000;
    while(1){
        select{
        case tmr when timerafter(t+delay):>t_new:
                int u = (2*l*counter)/((t_new - t)/ms);
                printf("Tile%d: Worker%u %d.%d CRCs/us of 100.0 possible\n" , Tile ,ID , u/1000 , u%1000);
                counter=0;
                tmr:>t;
                break;
        default:
        for(int i=l; i!=0; i--){
            crc32(checksum, counter, poly);
            crc32(checksum, counter, poly);
        }
         counter++;
            break;
        }
    }
}

const int p[]={103 , 107 , 109 , 113 , 127 , 131 , 137 , 139 , 149};

int main() {
    /* Channels to communicate with USB endpoints */
    chan c_ep_out[XUD_EP_COUNT_OUT], c_ep_in[XUD_EP_COUNT_IN];
    /* Interface to communicate with USB CDC (Virtual Serial) */
    interface usb_cdc_interface cdc_data[2];
    /* I2C interface */



    par
    {
        on USB_TILE:{set_core_high_priority_on();
                     xud(c_ep_out, XUD_EP_COUNT_OUT, c_ep_in, XUD_EP_COUNT_IN,
                         null, XUD_SPEED_HS, XUD_PWR_SELF);}

        on USB_TILE: {Endpoint0(c_ep_out[0], c_ep_in[0]);}

        on USB_TILE: CdcEndpointsHandler(c_ep_in[CDC_NOTIFICATION_EP_NUM1], c_ep_out[CDC_DATA_RX_EP_NUM1], c_ep_in[CDC_DATA_TX_EP_NUM1], cdc_data[0]);
        on USB_TILE: CdcEndpointsHandler(c_ep_in[CDC_NOTIFICATION_EP_NUM2], c_ep_out[CDC_DATA_RX_EP_NUM2], c_ep_in[CDC_DATA_TX_EP_NUM2], cdc_data[1]);

        on USB_TILE: [[combine]] par{ virtual_com_TEXTmode  (cdc_data[0]);
                                      virtual_com_BINARYmode(cdc_data[1]);}
        on USB_TILE: par(int i=0; i<3; i++)
                             worker(1 , i+1 , p[i]*ms*10);
/*
        on tile[0]:par(int i=0; i<5; i++)
                     worker(0, i+1 , p[i]*ms*10);
*/

    }
    return 0;
}
