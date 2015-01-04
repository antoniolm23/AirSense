/*
    This is the code that belongs to the sensderNore that is the external
    snesor, this code is based upon Andrea Gall's one, I added the part 
    related to XBee communication	
*/

#include <WaspXBee802.h>
#include <WaspFrame.h>
#include <WaspSensorGas_v20.h>

const char* filename = "DATA.TXT";

// create packet to send
packetXBee* packet;

int endFile = 4294967295;

//this is the sleeping time of the internal node
int intNodeSleep = 15000;
int extNodeSleep = 5000;
float CO_value=0.00;
float CO2_value=0.00;
float O3_value=0.00;
float NO2_value=0.00;
float VOC_value=0.00;
int TEMP_value=0;
int HUM_value=0;
int NODE_ID=1;
//char sentence[128];
//the maximum dimension of the SD buffer
char buffer[256];
int count=0;

//in the setup phase we turn on the xbee and usb modules
void setup()
{  
  //deletefile();
  // init USB port
  USB.ON();
  USB.println(F("senderNode"));
  
  RTC.ON();
  //use two digits for each field 
  RTC.setTime("14:11:29:07:17:13:00");
  
  // init XBee 
  xbee802.ON();
  
  // set 0x1212 as this XBee's Network Address (MY address)
  xbee802.setOwnNetAddress(0x12,0x12);

  // write values to XBee module memory
  xbee802.writeValues();
 
 xbee802.OFF(); 
  
  delay(1000);
}

void loop() 
{
  //////////////////////////////////////////////////////////////////////
  //THIS PART IS RELATED TO THE SD CARD THAT UP TO NOW I DON'T HAVE   //
  //////////////////////////////////////////////////////////////////////
  /*Utils.setLED(LED1, LED_ON);
  SD.ON();
  //Looking for data file in SD CARD
  if(SD.isFile("DATA.TXT")==1)
  {
    USB.println("File to send...");
    //int a=sendFTP();
  }
  else
  {
    USB.println("No File to send...");

  }
  SD.OFF();*/
  //////////////////////////////////////////////////////////////////////
  // END SD RELATED PART                                              //
  //////////////////////////////////////////////////////////////////////
  
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
  
  int ore,minuti,secondi,giorno,mese,anno;
  anno=getyear();
  mese=getmonth();
  giorno=getday();
  ore=gethour();
  minuti=getminute();
  secondi=getsecond();
  int error=0;
  //Build buffer for write on SD (if necessary)
  sprintf(buffer,"E: %d|%d|%d|%s|%s|%s|%s|%s|%d|%d|%d|%d|%d|%d|%d  &",\
  NODE_ID,PWR.getBatteryLevel(),TEMP_value,sCO_value,sCO2_value,sNO2_value,sO3_value,sVOC_value,HUM_value,anno,mese,giorno,ore,minuti,secondi);
  USB.println(buffer);
  
  //////////////////////////////////////////////////////////////////////
  //            SEND THE BUFFER PHASE                                 //
  //////////////////////////////////////////////////////////////////////
  
  
  //xbee802.setMode(XBEE_ON);
  //delay(1000);
  xbee802.ON();
  delay(1000);
  SD.ON();
    /*
  //create a new ASCII frame
  frame.createFrame(ASCII, "EXTNode");
  
  //fills the frame buffer, SENSOR_STR is a type
  frame.addSensor(SENSOR_STR, buffer); 
  
  // set packet parameters:
  packet=(packetXBee*) calloc(1,sizeof(packetXBee)); // memory allocation
  packet->mode=UNICAST; // set Unicast mode
  
  //sets Destination parameters (receiver address is 1111)
  xbee802.setDestinationParams(packet, "1111", frame.buffer, 
                               frame.length, MY_TYPE); 
  */
  // send data 
  int errorSend = 1;
  int continueSend = 1;
  int offset = 0;
  int last = 0;
  int lineSent = 0;
  /*
   * try for at max 30s to transmitt the packet
   * if the packet is correctly delivered then try 
   * to send the packets in the SD card */
  while(continueSend) {
    for(int i = 0; i < 6; i++) {
      USB.printf("for cycle %d\n", i);
      // 2.4 check TX flag
      sendPacket(buffer);
      if( xbee802.error_TX == 0) 
      {
        USB.println("ok");
        errorSend = 0;
        //now let's try to send other data
        /*if(SD.numln(filename) < lineSent) 
        {
          USB.println("File empty\n");
          continueSend = 0;
          break;
        }*/
        if(lineSent < SD.numln(filename) )
        {
          //the receiver buffer can contain at most 5 unread packets
          if(lineSent % 5 == 0)
            delay(intNodeSleep);
            
          //USB.println("Entered in the for");
          //USB.printf("%d , %d\n", offset, last);
          last = readline(offset);
          memcpy(buffer, SD.buffer, 256);
          USB.println(buffer);
          offset = last + offset + 1;
          i = 0;
          lineSent = lineSent + 1;
          //lineSent++;
        }
        else
          break;
      }
      else 
      {
        USB.println("send error");
        delay(extNodeSleep);
        if( i == 5 )
          continueSend = 0;
      }
    }
    continueSend = 0;
  }
  if(errorSend == 0) 
  {

    delay(intNodeSleep);
    /*
     * send the END message*/
     sendPacket(" END ");
     USB.println("send end\n");
     //retransmission in case of error (just one)
     if( xbee802.error_TX != 0)
     {
       delay(extNodeSleep);
       sendPacket(" END ");
     }
  }
  
  //shut down the antenna
  xbee802.OFF();
  //xbee802.setMode(XBEE_OFF);
  //////////////////////////////////////////////////////////////////////
  //       END SEND                                                   //
  //////////////////////////////////////////////////////////////////////
  
  
  //now we have to check if the packet has been sent, if not store on SD card
  if(errorSend != 0) 
  {
    USB.println("Send Failed\n");
    SD.ON();
    writefile(buffer);
    //SD.OFF();
    //showFile();
  }
  
  else
    deletefile();
  
  //in this part we have to check if the packets stored on SD where sent
  /*if(lineSent != SD.numln(filename)) 
  {
    SD.cat(filename, offset, endFile);
    deletefile();
    writefile(SD.buffer);
  } 
  */
  //
  SD.OFF();
  deepsleep();

}

//deepsleep function days:hours:minutes:seconds (is the sleep time)
void deepsleep()
{
  Utils.setLED(LED1, LED_OFF);
  PWR.deepSleep("00:00:30:00",RTC_OFFSET,RTC_ALM1_MODE1,ALL_OFF);

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





