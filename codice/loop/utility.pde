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
//return 0 if the date is correctly automatically setting on the waspmote
//return 1 else
int getdatefromserver()
{
  char sentence[100];
  int status=0;
  int counter=0;
  int error=0;
  char* answer;


  RTC.ON();
  
  error=httpSetup();
  if (error==0)
  {
    sprintf(sentence,"GET$/gethour.php");

    //USB.print("sentence:");
    //USB.println(sentence);
    status = WIFI.getURL(IP, IP_ADDRESS, 80,sentence);
    char* tmp;
    if( status == 1)
    {
      //USB.println(F("\nHTTP query OK."));
      //USB.print(F("WIFI.answer:"));

      answer=WIFI.answer;
      answer=strtok(answer,"$");

      while( answer != NULL ) 
      {
        answer = strtok(NULL, "$");
        if (counter==0)
          tmp=answer;
        counter++;

      }

      RTC.setTime(tmp);
     
      
      error=0;
    }

    else
    {
      error=1;
    }
  }
  else
  {
     error=1;
  }

  RTC.OFF();
  disconnectWIFI();
  return error;
}
