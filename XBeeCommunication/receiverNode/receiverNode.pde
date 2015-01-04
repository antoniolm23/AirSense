/*  
 *  ------ [802_04b] - receive packets using a 16-bit source address -------- 
 *  
 *  Explanation: This program shows how to receive packets with 
 *  XBee-802.15.4 modules. The source address is read when the
 *  packet is received
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
 *  Version:           0.2 
 *  Design:            David Gascón 
 *  Implementation:    Yuri Carmona
 */

//partire da pos = 0!!
//handler messaggi xbee

#include <WaspXBee802.h>
#include <WaspFrame.h>
#include <WaspSensorGas_v20.h>

//microsleep of 15 seconds
#define microsleep 15000

packetXBee* packet;

float CO_value=0.00;
float CO2_value=0.00;
float O3_value=0.00;
float NO2_value=0.00;
float VOC_value=0.00;
int TEMP_value=0;
int HUM_value=0;
//char sentence[128];
//the maximum dimension of a XBee frame buffer is 159 bytes
int count=0;
int NODE_ID = 0;
int beaconCycles = 60;
int receiveCycles = 20;
int synchronizationCycle;
// variable to store source's network address
uint8_t network_address[2];
char buffer[256]; //it's the space reserved to the xbee packet received
uint8_t received;

/*USB.print(F("Data: "));             
        for( int i=0 ; i < xbee802.packet_finished[xbee802.pos-1]->data_length ; i++)          
        {           
          USB.print(xbee802.packet_finished[xbee802.pos-1]->data[i],BYTE);          
        }*/

void setup()
{ 
  // init XBee 
  xbee802.ON();
  delay(1000);
  // init USB port
  USB.ON();
  USB.println(F("receiver node"));  
  
  // set 0x1111 as this XBee's Network Address (MY address)
  xbee802.setOwnNetAddress(0x11,0x11);
  if( xbee802.error_AT == 0 ) 
  {
    USB.println(F("Network set OK"));
  }
  else 
  {
    USB.println(F("Error setting Network"));  
  }
  xbee802.setChannel(0x0F);
  if( xbee802.error_AT == 0 ) 
  {
    USB.println(F("Channel set OK"));
  }
  else 
  {
    USB.println(F("Error setting Channel"));  
  }

  
  // write values to XBee module memory
  xbee802.writeValues(); 
  
  received = 0;
  RTC.ON();
  RTC.setTime("11:04:05:05:12:15:00");
  
  synchronizationCycle = 0;
}


void loop()
{ 
  //xbee802.setMode(XBEE_ON);
    // init XBee 
  xbee802.ON();
  delay(1000);
  /*  SYNCHRONIZATION phase with beacons each 20 sec a beacon 
      will be sent until the first received one.
      To avoid infinite wait (external sensor may break up)
      The beacons will be sent for at most 35 minutes (that is equal
      to the total time of the external sensor)
      The synchronization phase will be executed roughly every 4-5 hours
      or when the internalNode wakes up
   */
  int beaconReceived = 0;
  if(synchronizationCycle == 0)
  {
    for(int j = 0; j < 105 || beaconReceived == 1; j++)
    {
      USB.println("sending beacons");
      sendPacket("Beacon");
      if(xbee802.error_TX == 0)
      {
        beaconReceived = 1;
        USB.println("Beacon received\n");
        synchronizationCycle = synchronizationCycle + 1;
        break;
      }
      else
        delay(20000);
    }
  }
  else
  {
    beaconReceived = 1;
    synchronizationCycle = synchronizationCycle + 1;
  }
  
  /*******Now wait for the packet to arrive, nodes are synchronized********/
  
  //in case the beacon hasn't been received, skip the receiving phase
  int i;  
  
  
  received = 0;
  int pos, lastPos;
  USB.println("receiver node UP");
  int lastCycle;
  //try 20 times to receive the packet, waits at most 300s
  for(i = 0; i < receiveCycles; i++) 
  {
    //in case in which the beacon hasn't been received, the external node 
    //was off so skip this phase
    if(beaconReceived == 0)
    {
      i = receiveCycles;
      break;
    }
    USB.println("searching data\n");
    // check available data in RX buffer
    if( xbee802.available() > 0 ) 
    {
      // parse information
      xbee802.treatData(); 
    
      // check RX flag after 'treatData'
      if( !xbee802.error_RX ) 
      {
        while(xbee802.pos > 0) 
        {
          lastPos = xbee802.pos;
          pos = 0;
        // check available packets
          while( pos < lastPos  )
          {
            USB.printf("pos: %d, lastPos: %d, XPos: %d\n", pos, lastPos, xbee802.pos);
            //USB.println((char*)xbee802.packet_finished[xbee802.pos-1]->data);
            //to state the end of a communication the external node sends and END message composed of
            if( strstr(xbee802.packet_finished[pos]->data, "END") != NULL && pos == (lastPos - 1))
            {
              USB.println("Closing frame found");
              received = 1;
            }
            else {
	      for( int j=0 ; j < xbee802.packet_finished[pos]->data_length ; j++)          
              {           
                buffer[j] = xbee802.packet_finished[pos]->data[j];          
              }
              //wait for the end frame
              i = 0;
              USB.println(buffer);
              USB.println("\n");
              /*clear the buffer*/
              for( int j = 0; j < 256; j++ )
                buffer[j] = '\0';
            }
	  
            free(xbee802.packet_finished[pos]); //free memory
            xbee802.packet_finished[pos]=NULL; //free pointer
            pos ++; //Increment the received packet counter  
          }
          xbee802.pos = xbee802.pos - pos;
        }
      }	  
    }
    else 
    {
	  delay(microsleep);
    }
    if(received == 1) {
      USB.println("sleep time:");
      //int c = i * microsleep;
      USB.printf("%i, %i\n", i, microsleep);
      break;
    }
      
  }
  
  xbee802.OFF();
  USB.println("Out");
  beaconReceived = 0;
  //USB.println(buffer);
  /*USB.print(F("Data: "));             
        for( int i=0 ; i < xbee802.packet_finished[xbee802.pos-1]->data_length ; i++)          
        {           
          USB.print(xbee802.packet_finished[xbee802.pos-1]->data[i],BYTE);          
        }*/

        //USB.println();
  
  //xbee802.OFF();
  //xbee802.setMode(XBEE_OFF);
  //now it's time to turn off the radio
  
    //send to the PC the buffer received
    	
	//Now the packet may be either received or not, if the timeout has expired
	
	//Power ON the GAS Sensor Board
  SensorGasv20.ON();
  
  //////////////////////////////////////////////////////////////////////
  //                  BEGIN SENSOR ACQUISITION PHASE                  //
  //////////////////////////////////////////////////////////////////////
  TEMP_value=tempsense();
  delay(5000);

  CO_value=COsense();
  delay(5000);

  CO2_value=CO2sense();
  delay(5000);

  NO2_value=NO2sense();
  delay(5000);

  O3_value=O3sense();
  delay(5000);

  HUM_value=HUMsense();
  //////////////////////////////////////////////////////////////////////
  //                  END SENSOR ACQUISITION PHASE                    //
  //////////////////////////////////////////////////////////////////////
  
  //Power OFF the GAS Sensor Board
  SensorGasv20.OFF();
  
  //CONVERSION FROM ORIGINAL TYPE TO STRING
  char sbattery_level[4];
  char sCO_value[10];
  char sCO2_value[8];
  char sNO2_value[8];
  char sO3_value[8];
  char sVOC_value[8];
  
  Utils.float2String(CO_value,sCO_value,4);
  Utils.float2String(CO2_value,sCO2_value,4);
  Utils.float2String(NO2_value,sNO2_value,4);  
  Utils.float2String(O3_value,sO3_value,4);
  Utils.float2String(VOC_value,sVOC_value,4);
  //compute the buffer, the I letter stands for internal
  sprintf(buffer,"I: %d|%d|%d|%s|%s|%s|%s|%s|%d|",\
  NODE_ID,PWR.getBatteryLevel(),TEMP_value,sCO_value,sCO2_value,
  sNO2_value, sO3_value,sVOC_value,HUM_value);
  //send to the pc the values just read
  USB.println(buffer); 
  
  deepsleep();
  
} 

//deepsleep function days:hours:minutes:seconds (is the sleep time)
void deepsleep()
{
  
  Utils.setLED(LED1, LED_OFF);
  PWR.deepSleep("00:00:29:00",RTC_OFFSET,RTC_ALM1_MODE1,ALL_OFF);

  USB.ON();
  USB.println(F("UP"));

  // After wake up I check intFlag and blink LEDs
  if( intFlag & RTC_INT )
  {    
    Utils.blinkLEDs(300);
    Utils.blinkLEDs(300);
    Utils.blinkLEDs(300);
    // Reset INT flag restart from loop
    intFlag &= ~(RTC_INT);
  }
}


