
#include <WaspXBee802.h>
#include <WaspFrame.h>
#include <WaspSensorGas_v20.h>
#include <wiring.h>

//microsleep of 30 seconds
#define microsleep 30000

packetXBee* packet;

// variable to store source's network address
uint8_t network_address[2];
char buffer[159]; //it's the space reserved to the xbee packet received
char buffer2[318];
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

}


void loop()
{ 
  USB.println("loop\n");
  //xbee802.setMode(XBEE_ON);
    // init XBee 
  xbee802.ON();
  delay(1000);
  int i;
  int pos = 0;
  received = 0;
  PWR.deepSleep("00:00:04:00", RTC_OFFSET, RTC_ALM1_MODE1, ALL_ON);
  if( intFlag & XBEE_INT) 
  {
    USB.println("data received!!!!!\n");
  }
  if(intFlag & RTC_INT)
  {
    USB.println("Timeout expired\n");
    intFlag &= ~(RTC_INT);
  }
  disableInterrupts(XBEE_INT);
  PWR.clearInterruptionPin();
  USB.println("receiver node UP");
  int lastCycle;
  //try ten times to receive the packet, waits at most 300s
  if( xbee802.available() > 0 ) 
  {
    // parse information
    xbee802.treatData(); 
    
    // check RX flag after 'treatData'
    if( !xbee802.error_RX ) 
    {
      // check available packets
      while( pos < xbee802.pos )
      {
        USB.println("Data received!\n");
        //USB.println((char*)xbee802.packet_finished[xbee802.pos-1]->data);
        //to state the end of a communication the external node sends and END message composed of
        if( strstr(xbee802.packet_finished[pos]->data, "END\n") != NULL)
        {
          USB.println("Closing frame found");
          received = 1;
        }
        else 
        {
	  for( int j=0 ; j < xbee802.packet_finished[pos]->data_length ; j++)          
          {           
            buffer[j] = xbee802.packet_finished[pos]->data[j];          
          }
          //wait for the end frame
          i = 0;
          USB.println(buffer);
        }
	  
        free(xbee802.packet_finished[pos]); //free memory
        xbee802.packet_finished[pos]=NULL; //free pointer
        pos++; //Decrement the received packet counter   
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
      //break;
    }
  xbee802.OFF();
}

