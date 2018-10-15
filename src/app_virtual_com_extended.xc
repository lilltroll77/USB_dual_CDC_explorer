// Copyright (c) 2016, XMOS Ltd, All rights reserved

#include <platform.h>
#include <xs1.h>
#include <stdio.h>
#include <string.h>
#include <timer.h>
#include "xud_cdc.h"

#define USB_MICROPACKAGE_LEN 64

[[combinable]]void virtual_com_BINARYmode(client interface usb_cdc_interface cdc)
{
    char data[USB_MICROPACKAGE_LEN];
    unsigned len;
    cdc.data_ready_size(1);
    timer tmr;
    unsigned t;
     while(1)
        select{
        case cdc.data_ready():
            len = cdc.get_char();
            unsigned bytes=cdc.available_bytes();
            while(bytes < len){
                    unsigned dt = 100*(len-bytes);
                    if(dt<200);
                     dt=200;
                    tmr:>t;
                    tmr when timerafter(t + dt):> unsigned _;
                    bytes=cdc.available_bytes();
            }
            cdc.read(data , len);
            //Process data and send something back
            for(unsigned i=0; i< len; i++){
                data[i]++;

            }
            cdc.put_char(len);
            cdc.write(data , len);
            break;

    }
}


/* Application task */
[[combinable]]void virtual_com_TEXTmode(client interface usb_cdc_interface cdc)
{

    set_core_high_priority_off();
    char data[USB_MICROPACKAGE_LEN];
    unsigned t;
    timer tmr;
    tmr:>t;
    unsigned len;
    while(1)
        select{
        case cdc.data_ready():
            len = cdc.available_bytes();
            while( len >0 ){
                if(len > USB_MICROPACKAGE_LEN)
                    len=USB_MICROPACKAGE_LEN;
                cdc.read( data, len);
                cdc.write(data, len);
                len = cdc.available_bytes();
            }
            break;
        }
}
