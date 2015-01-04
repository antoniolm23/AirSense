/*  
 *  ------ [802_06b] - receive broadcast packets  -------- 
 *  
 *  Explanation: This program shows how to receive packets with 
 *  XBee-802.15.4 modules. The packets received were broadcast
 *  
 *  Copyright (C) 2012 Libelium Comunicaciones Distribuidas S.L. 
 *  http://www.libelium.com 
 *  
 *  This program is free software: you can redistribute it and/or modify 
 *  it under the terms of the GNU General Public License as published by 
 *  the Free Software Foundation, either version 3 of the License, or 
 *  (at your option) any later version. 
 *  
 *  This program is distributed in the hope that it will be useful, 
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of 
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the 
 *  GNU General Public License for more details. 
 *  
 *  You should have received a copy of the GNU General Public License 
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>. 
 *  
 *  Version:           0.1 
 *  Design:            David Gascón 
 *  Implementation:    Yuri Carmona
 */

#include <WaspXBee802.h>

// variable to store source's network address
uint8_t source_address[8];

uint8_t  PANID[2]={0x00,0x00};

void setup()
{ 
 
  // init USB port
  USB.ON();
  USB.println(F("802_06b example"));
  
  // init XBee 
  xbee802.ON();  
}


void loop()
{   
  // check available data in RX buffer
  if( xbee802.available() > 0 ) 
  {
    // parse information
    xbee802.treatData(); 

    // check RX flag after 'treatData'
    if( !xbee802.error_RX ) 
    {
      // check available packets
      while( xbee802.pos>0 )
      {
        USB.println(F("\n\nNew packet received:")); 
        USB.println(F("---------------------------"));
        
        /*** Available info in 'xbee802.packet_finished' structure ***/
        source_address[0]=xbee802.packet_finished[xbee802.pos-1]->macSH[0];
        source_address[1]=xbee802.packet_finished[xbee802.pos-1]->macSH[1];
        source_address[2]=xbee802.packet_finished[xbee802.pos-1]->macSH[2];	
        source_address[3]=xbee802.packet_finished[xbee802.pos-1]->macSH[3];
        source_address[4]=xbee802.packet_finished[xbee802.pos-1]->macSL[0];
        source_address[5]=xbee802.packet_finished[xbee802.pos-1]->macSL[1];
        source_address[6]=xbee802.packet_finished[xbee802.pos-1]->macSL[2];	
        source_address[7]=xbee802.packet_finished[xbee802.pos-1]->macSL[3];

        USB.print(F("source_address: "));
        USB.printHex(source_address[0]);
        USB.printHex(source_address[1]);
        USB.printHex(source_address[2]);
        USB.printHex(source_address[3]);
        USB.printHex(source_address[4]);
        USB.printHex(source_address[5]);
        USB.printHex(source_address[6]);
        USB.printHex(source_address[7]); 
        USB.println();      

        USB.print(F("Data: "));             
        for( int i=0 ; i < xbee802.packet_finished[xbee802.pos-1]->data_length ; i++)          
        {           
          USB.print(xbee802.packet_finished[xbee802.pos-1]->data[i],BYTE);          
        }
        USB.println(F("\n---------------------------"));        

        // free memory
        free(xbee802.packet_finished[xbee802.pos-1]);
        xbee802.packet_finished[xbee802.pos-1]=NULL; 

        // decrement the received packet counter
        xbee802.pos--; 
      }
    }
  }
} 



