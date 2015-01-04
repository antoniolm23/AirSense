/*  
 *  ------ USENSE trxWIFI MODULE -------- 
 *  
 *  Explanation: This module deals with the transmission of data via
 *  wifi 802.11 , the settings of the AP are in the DEFINE module ,
 *  for other changes you need to change the function httpSetup
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


// if error=1 tx error, write buffer on SD
int trytx(char* sentence)
{

  int error;
  error=sendsentence(sentence);
  if (error==0)
    exit;
  else if (error==1)
  {
    delay(RETX1);
    error=sendsentence(sentence);
  }
  if (error==0)
    exit;
  else if (error==1)
  {
    delay(RETX2);
    error=sendsentence(sentence);
  }
  if (error==0)
    exit;
  else if (error==1)
  {
    delay(RETX3);
    error=sendsentence(sentence);
  }
  if (error==0)
    exit;
  else if (error==1)
  {
    delay(RETX4);
    error=sendsentence(sentence);
  }

  return error;

}


//if error 1 tx error write file on SD

int sendsentence(char* sentence)
{
  uint8_t status;
  status=WIFI.getURL(IP,IP_ADDRESS,sentence);
  int error=0;
  USB.print("-- sentence:");
  USB.println(sentence);

  if(status == 1)
  {
    USB.println(F("\nHTTP query OK"));
    error=0;
  }
  else
  {
    USB.println(F("\nHTTP query ERROR"));
    error=1;

  }
  return error;
}

//try to connect to AP
//return 1 in case of problem
int httpSetup()
{
  uint8_t status;
  int error=0;
  if(WIFI.ON(SOCKET0) == 1)
  {    
    USB.println(F("*ACCENDO WIFI"));
    error=0;
  }
  else
  {
    USB.println(F("*WIFI NON INIZIALIZZATO"));
    error=1;
  }

  WIFI.setConnectionOptions(HTTP|CLIENT_SERVER);
  WIFI.setDHCPoptions(DHCP_ON);
  WIFI.setAuthKey(WPA2, AUTHKEY); 
  WIFI.setJoinMode(MANUAL);
  WIFI.storeData();


  if (WIFI.join(ESSID)) 
  { 
    USB.println(F("* JOINED AP"));
    error=0;

  }
  else
  {
    USB.println(F("*NOT JOINED AP"));
    error=1;

  }  

  return error; 
}

void disconnectWIFI()
{
  WIFI.OFF();  
  delay(500);
}


