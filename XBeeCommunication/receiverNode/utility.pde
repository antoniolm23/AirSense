/*
 * Part implemented by
 * Antonio La Marra
 */
//function that sends a packet via XBee
int sendPacket(char* buffer)
{
  //create a new ASCII frame
  frame.createFrame(ASCII, "EXTNode");
  
  //fills the frame buffer, SENSOR_STR is a type
  frame.addSensor(SENSOR_STR, buffer); 
  
  // set packet parameters:
  packet=(packetXBee*) calloc(1,sizeof(packetXBee)); // memory allocation
  packet->mode=UNICAST; // set Unicast mode
  
  //sets Destination parameters (receiver address is 1111)
  xbee802.setDestinationParams(packet, "1212", frame.buffer, 
                               frame.length, MY_TYPE); 
  xbee802.sendXBee(packet);
  
  free(packet);
  packet=NULL;
  
  return xbee802.error_TX;
}
