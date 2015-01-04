/*  
 *  ------ USENSE DEFINE MODULE -------- 
 *  
 *  Explanation: This is the USENSE define module
 *  you can change the delay, the server data, the
 *  WIFI key and the file name on SD
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



//--- FTP SERVER ---\\

#define FOLDER "."
#define SERVER_FTP "131.114.58.116"

#define FTP_USER "ftpuser"
#define FTP_PASS "simdom"
#define PORTFTP 21
#define FILENAME "DATA.TXT"
#define SD_FOLDER "." //select Root Directory

//--- DEFINISCO PERIODO TRASMISSIONE --\\

#define RETX1 2000 //ms
#define RETX2 10000
#define RETX3 60000
#define RETX4 RETX3*3

//--- DATI WIFI---\\

//UNIPI

#define ESSID "SerraUnipi"
#define AUTHKEY "wifi-unipi"



//--- WEBSERVER ---\\

#define IP_ADDRESS "131.114.58.116"
#define PORT 80

//--- SW VERISON ---\\
#define VERSION  1.0  //Versione SW

//--- CALIBRAZIONE SENSORI ---\\


#define GAIN_CO2  7  //GAIN of the sensor stage 
 
#define VOLTAGE_CO2  1.5796773433  //TENSIONE a 350 PPm circa

#define GAIN_CO  1      // GAIN of the sensor stage
#define RESISTOR_CO 5  // LOAD RESISTOR of the sensor stage
#define RESISTOR_R0CO 12 // RESISTENZA A 100 PPM

#define GAIN_NO2  1      //GAIN of the sensor stage
#define RESISTOR_NO2 30  //LOAD RESISTOR of the sensor stage
#define RESISTOR_R0NO2 24 //R0 in aria tecnica

#define GAIN_O3 1  //LOAD RESISTOR of the sensor stage
#define RESISTOR_O3 24  //LOAD RESISTOR of the sensor stage

#define GAIN_VOC 3  //LOAD RESISTOR of the sensor stage
#define RESISTOR_VOC 85  //LOAD RESISTOR of the sensor stage

//--- DELAY ---\\

#define DELAYCO2 30000
#define DELAYCO 30000
#define DELAYNO2 30000
#define DELAYO3 30000
#define DELAYVOC 30000
#define DELAYTEMP 2000



