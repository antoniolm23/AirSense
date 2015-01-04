uint8_t  PANID[2]={0x12,0x34};
char*  KEY="WaspmoteKey";

void setup()
{
  // Inits the XBee 802.15.4 library
  xbee802.init(XBEE_802_15_4,FREQ2_4G,NORMAL);
  USB.ON();
  // Powers XBee
  xbee802.ON();
}

void loop()
{
  // Chosing a channel : channel 0x0D
  xbee802.setChannel(0x0D);
  if( !xbee802.error_AT ) USB.println("Channel set OK");
  else USB.println("Error while changing channel");

  // Chosing a PANID : PANID=0x1234
  xbee802.setPAN(PANID);
  if( !xbee802.error_AT ) USB.println("PANID set OK");
  else USB.println("Error while changing PANID");

  // Enabling security : KEY="WaspmoteKey"
  xbee802.encryptionMode(1);
  if( !xbee802.error_AT ) USB.println("Security enabled");
  else USB.println("Error while enabling security");

  xbee802.setLinkKey(KEY);
  if( !xbee802.error_AT ) USB.println("Key set OK");
  else USB.println("Error while setting Key");

  // Keep values
  xbee802.writeValues();
  if( !xbee802.error_AT ) USB.println("Changes stored OK");
  else USB.println("Error while storing values");

  delay(3000);
}
