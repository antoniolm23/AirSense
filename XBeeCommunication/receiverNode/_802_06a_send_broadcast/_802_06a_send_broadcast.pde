/*  
 *  ------ [802_06a] - broadcast packets  -------- 
 *  
 *  Explanation: This program shows how to send packets with 
 *  XBee-802.15.4 modules. Broadcast address (0x000000000000FFFF)
 *  is specified as destination address
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
#include <WaspFrame.h>

// create packet to send
packetXBee* packet; 


void setup()
{  
  // init USB port
  USB.ON();
  USB.println(F("802_06a example"));

  // init XBee 
  xbee802.ON();  
}


void loop()
{    
  ///////////////////////////////////////////
  // 1. Create ASCII frame
  ///////////////////////////////////////////  
  
  xbee802.getPAN();
  USB.print(F("panid: "));
  USB.printHex(xbee802.PAN_ID[0]); 
  USB.printHex(xbee802.PAN_ID[1]); 
  USB.println(); 
  
  xbee802.getEncryptionMode();
  USB.print(F("encryption mode: "));
  USB.printHex(xbee802.encryptMode);
  USB.println(); 
  
  xbee802.getChannel();
  USB.print(F("channel: "));
  USB.printHex(xbee802.channel);
  USB.println();

  
  // 1.1. create new frame
  frame.createFrame(ASCII, "WASPMOTE_06a");  
  
  // 1.2. add frame fields
  frame.addSensor(SENSOR_STR, "This is a broadcast message"); 
  
  
  ///////////////////////////////////////////
  // 2. Send packet
  /////////////////////////////////////////// 
  
  // 2.1. set packet to send:
  packet=(packetXBee*) calloc(1,sizeof(packetXBee)); // memory allocation
  packet->mode=BROADCAST; // set Unicast mode

  // 2.2. sets Destination parameters
  xbee802.setDestinationParams(packet, "000000000000FFFF", frame.buffer, frame.length, MAC_TYPE); 

  // 2.3. send data
  xbee802.sendXBee(packet);

  // 2.4. Check TX flag
  if( !xbee802.error_TX ) USB.println(F("ok"));
  else USB.println(F("error")); 

  // 2.5. free memory
  free(packet);
  packet=NULL; 

  delay(3000);
} 


