/*  
 *  ------ USENSE sendFTP MODULE -------- 
 *  
 *  Explanation: This module deals with the transmission of 
 *  the file to the web server to the sensor parameters are
 *  specified in the module define
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

#include <WaspWIFI.h>

int sendFTP()
{   
  int error=0;
  ftpSetup();
  if( WIFI.ON(SOCKET0) == 1 )
  {    
    USB.println(F("Switched ON"));

    // If it is manual, call join giving the name of the AP     
    if( WIFI.join(ESSID) )
    {
      USB.println(F("Joined AP.\nUploading file...")); 

      // **** UPLOAD  ****
      if(WIFI.uploadFile(FILENAME, SD_FOLDER, FOLDER) == 1)
      {  
        USB.println(F("UPLOAD OK")); 
      } 
      else
      {
        USB.println(F("UPLOAD ERROR"));   
        error=1;     
      }
    }
    else
    {
      USB.println(F("ERROR joining"));
      error=1;
    }
  }
  else
  {
    USB.println(F("ERROR switching on"));
    error=1;
  }

  // switch off the module 
  
    if (error==0)
    {
       httpSetup();
       sprintf(sentence,"GET$/file.php");
       int q=sendsentence(sentence);
       if (q==0) {
         deletefile();
       }
    }
  
  WIFI.OFF();  
  USB.println(F("**********************"));  
  delay(500);
} 


/**********************************************************
 *
 *  wifiSetup - It sets the proper configuration to the WiFi 
 *  module prior to the attemp of uploading the file
 *
 ************************************************************/
int ftpSetup()
{
  int error=0;
  // Switch ON the WiFi module on the desired socket
  if( WIFI.ON(SOCKET0) == 1 )
  {    
    //USB.println(F("WiFi switched ON"));
    error=0;
  }
  else
  {
    //USB.println(F("WiFi did not initialize correctly"));
    error=1;
  }

  // 1. Configure the transport protocol (UDP, TCP, FTP, HTTP...) 
  WIFI.setConnectionOptions(CLIENT_SERVER); 
  // 2. Configure the way the modules will resolve the IP address. 
  WIFI.setDHCPoptions(DHCP_ON); 
  // 3. Set the Flush buffer to 700 Bytes (DO NOT CHANGE)
  WIFI.setCommSize(700); 
  // 4. Set the Flush Timer to 50ms (DO NOT CHANGE)
  WIFI.setCommTimer(50);
  // 5. Set TX rate to 1Mbps (DO NOT CHANGE)
  WIFI.setTXRate(0);

  // 6. Set the server IP address, ports and FTP mode 
  WIFI.setFTP(SERVER_FTP,PORTFTP,FTP_PASIVE,20); 

  // 7. Set the server account with the username and password 
  WIFI.openFTP(FTP_USER,FTP_PASS); 

  // 8. Configure how to connect the AP 
  WIFI.setJoinMode(MANUAL); 

  // 9. Set the AP authentication key
  WIFI.setAuthKey(WPA2,AUTHKEY); 

  // 10. Save Data to module's memory
  WIFI.storeData();
  return error;

}


