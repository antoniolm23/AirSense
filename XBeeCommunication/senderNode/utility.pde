/*  
 *  ------ USENSE Utility MODULE -------- 
 *  
 *  Explanation: This module contains utility functions 
 *  and the function to retrieve the date and time from the server
 *   
 *  
 *  This program is distributed in the hope that it will be useful, 
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of 
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the 
 *  GNU General Public License for more details. 
 *  
 *  You should have received a copy of the GNU General Public License 
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>. 
 *  
 *  Version:           1.2
 *  Design:            Andrea Galli 
 *  Implementation:    Andrea Galli
 */

//return hour hh
int gethour()
{
  int data;
  RTC.ON(); 
  data=RTC.hour;

  RTC.OFF();
  return data;

}
//return minute mm
int getminute()
{
  int data;
  RTC.ON(); 
  data=RTC.minute;

  RTC.OFF();
  return data;

}
//return seconds ss
int getsecond()
{
  int data;
  RTC.ON(); 
  data=RTC.second;

  RTC.OFF();
  return data;

}
//retun month MM
int getmonth()
{
  int data;
  RTC.ON(); 
  data=RTC.month;

  RTC.OFF();
  return data;
}
//retun day DD
int getday()
{
  int data;
  RTC.ON(); 
  data=RTC.date;

  RTC.OFF();
  return data;
}
//retun year YY
int getyear()
{
  int data;
  RTC.ON(); 
  data=RTC.year;

  RTC.OFF();
  return data;
}

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
  xbee802.setDestinationParams(packet, "1111", frame.buffer, 
                               frame.length, MY_TYPE); 
  xbee802.sendXBee(packet);
  
  free(packet);
  packet=NULL;
  
  return xbee802.error_TX;
}
