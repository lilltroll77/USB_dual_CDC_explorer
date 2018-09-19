// Copyright (c) 2016, XMOS Ltd, All rights reserved

#include <platform.h>
#include <xs1.h>
#include <stdio.h>
#include <string.h>
#include <timer.h>
#include "xud_cdc.h"


/* Application task */
void app_virtual_com_extended(client interface usb_cdc_interface cdc , char id)
{
    char data[512];
    unsigned t;
    timer tmr;
    tmr:>t;
    int first=1;
    unsigned char str[]="XMOS loopbackX: ";
    unsigned len = sizeof(str);
    str[13] = '0'+id;
    while(1)
        select{
        case cdc.data_ready():
            if(first){
                cdc.write(str, len);
                first =0;
            }
            unsigned bytes;
            do{
                bytes = cdc.available_bytes();
                if(bytes > 512)
                    bytes=512;
                cdc.read( data, bytes);
                cdc.write(data, bytes);
            }
            while( bytes >512 );

            break;
        }
}
