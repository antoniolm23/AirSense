/*  
 *  ------ [802_01] - configure XBee basic parameters -------- 
 *  
 *  Explanation: This program shows how to configure basic XBee
 *  parameters in order to communicate between different XBee 
 *  devices using the same network. 
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

// PAN (Personal Area Network) Identifier
uint8_t  PANID[2]={0x00,0x00}; 

// 16-byte Encryption Key
char*  KEY="WaspmoteLinkKey!"; 


void setup()
{
  // open USB port
  USB.ON();
  USB.println(F("802_01 example"));


  // init XBee 
  xbee802.ON();


  // wait for a second
  delay(1000);

  /////////////////////////////////////
  // 1. set channel 
  /////////////////////////////////////
  xbee802.setChannel(0x0F);

  // check at commmand execution flag
  if( xbee802.error_AT == 0 ) 
  {
    USB.println(F("Channel set OK"));
  }
  else 
  {
    USB.println(F("Error setting channel"));
  }


  /////////////////////////////////////
  // 2. set PANID
  /////////////////////////////////////
  xbee802.setPAN(PANID);

  // check the AT commmand execution flag
  if( xbee802.error_AT == 0 ) 
  {
    USB.println(F("PANID set OK"));
  }
  else 
  {
    USB.println(F("Error setting PANID"));  
  }

  /////////////////////////////////////
  // 3. set encryption mode (1:enable; 0:disable)
  /////////////////////////////////////
  xbee802.setEncryptionMode(0);

  // check the AT commmand execution flag
  if( xbee802.error_AT == 0 ) 
  {
    USB.println(F("encryption set OK"));
  }
  else 
  {
    USB.println(F("Error setting security"));  
  }

  /////////////////////////////////////
  // 4. set encryption key
  /////////////////////////////////////
  xbee802.setLinkKey(KEY);

  // check the AT commmand execution flag
  if( xbee802.error_AT == 0 ) 
  {
    USB.println(F("encryption key set OK"));
  }
  else 
  {
    USB.println(F("Error setting encryption key"));  
  }

  /////////////////////////////////////
  // 5. write values to XBee module memory
  /////////////////////////////////////
  xbee802.writeValues();

  // check the AT commmand execution flag
  if( xbee802.error_AT == 0 ) 
  {
    USB.println(F("write values OK"));
  }
  else 
  {
    USB.println(F("Error writing values"));  
  }

  USB.println(F("-------------------------------")); 
}

void loop()
{

  /////////////////////////////////////
  // 1. get channel 
  /////////////////////////////////////
  xbee802.getChannel();
  USB.print(F("channel: "));
  USB.printHex(xbee802.channel);
  USB.println();

  /////////////////////////////////////
  // 2. get PANID
  /////////////////////////////////////
  xbee802.getPAN();
  USB.print(F("panid: "));
  USB.printHex(xbee802.PAN_ID[0]); 
  USB.printHex(xbee802.PAN_ID[1]); 
  USB.println(); 

  /////////////////////////////////////
  // 3. get encryption mode (1:enable; 0:disable)
  /////////////////////////////////////
  xbee802.getEncryptionMode();
  USB.print(F("encryption mode: "));
  USB.printHex(xbee802.encryptMode);
  USB.println(); 

  USB.println(F("-------------------------------")); 

  delay(3000);
}




