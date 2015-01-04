/*  
 *  ------ USENSE MAIN MODULE -------- 
 *  
 *  Explanation: Main file for execution USENSE WIFI NODE
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
 
#include <WaspSensorGas_v20.h>
#include <WaspWIFI.h>

float CO_value=0.00;
float CO2_value=0.00;
float O3_value=0.00;
float NO2_value=0.00;
float VOC_value=0.00;
int TEMP_value=0;
int HUM_value=0;
int NODE_ID=1;
char sentence[128];
char buffer[256];
int count=0;
void setup()
{
  //Turn on the USB and print a start message
  USB.ON();
  count=0;
  RTC.ON();
  int result=0;
  //set automatically the time from server
  // try to take hour
  do
  {
    result=getdatefromserver();
    count++;
    
  }
  while(result==1 && count<5);
  //uncomment for set manually date and time
  
  //RTC.setTime("14:10:10:02:13:19:00");
  if (result==1)
    RTC.setTime("00:00:00:02:00:00:00");
  USB.println(F("start"));
  delay(500);
}

void loop()
{


  Utils.setLED(LED1, LED_ON);
  SD.ON();
  //Looking for data file in SD CARD
  if(SD.isFile("DATA.TXT")==1)
  {
    USB.println("File to send...");
    int a=sendFTP();
  }
  else
  {
    USB.println("No File to send...");

  }
  SD.OFF();
  //Power ON the GAS Sensor Board
  SensorGasv20.ON();

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
  //Power OFF the GAS Sensor Board
  SensorGasv20.OFF();

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
  sprintf(buffer,"%d|%d|%d|%s|%s|%s|%s|%s|%d|%d|%d|%d|%d|%d|%d",\
  NODE_ID,PWR.getBatteryLevel(),TEMP_value,sCO_value,sCO2_value,sNO2_value,sO3_value,sVOC_value,HUM_value,anno,mese,giorno,ore,minuti,secondi);
  // try to connect to AP
  error+=httpSetup();
  // if connection is OK try to send data in 4 packet ( this for limitation of the buffer module )
  // the key is NODE_ID, anno, mese, giorno,ore minuti, secondi
  if (error==0)
  {
    sprintf(sentence,"GET$/s1.php?v=%d|%d|%d|%d|%d|%d|%d|%d|%d",NODE_ID,anno,mese,giorno,ore,minuti,secondi,PWR.getBatteryLevel(),TEMP_value);
    error+=trytx(sentence);

    sprintf(sentence,"GET$/s2.php?v=%d|%d|%d|%d|%d|%d|%d|%s|%s",NODE_ID,anno,mese,giorno,ore,minuti,secondi,sCO_value,sCO2_value);
    error+=trytx(sentence);

    sprintf(sentence,"GET$/s3.php?v=%d|%d|%d|%d|%d|%d|%d|%s|%s",NODE_ID,anno,mese,giorno,ore,minuti,secondi,sNO2_value,sO3_value);
    error+=trytx(sentence);

    sprintf(sentence,"GET$/s4.php?v=%d|%d|%d|%d|%d|%d|%d|%s|%d",NODE_ID,anno,mese,giorno,ore,minuti,secondi,sVOC_value,HUM_value);
    error+=trytx(sentence);

    if (error>0)
    {
      SD.ON();
      writefile(buffer);
      SD.OFF();
      exit;
    }
  }
  else
  {
    SD.ON();
    writefile(buffer);
    SD.OFF();
  }
  disconnectWIFI();
  deepsleep();
}
//deepsleep function days:hours:minutes:seconds (is the sleep time)
void deepsleep()
{
  Utils.setLED(LED1, LED_OFF);
  PWR.deepSleep("00:00:26:00",RTC_OFFSET,RTC_ALM1_MODE1,ALL_OFF);

  USB.ON();
  USB.println(F("WAKE UP"));

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









