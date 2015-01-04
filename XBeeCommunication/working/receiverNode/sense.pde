/*  
 *  ------ USENSE sense MODULE -------- 
 *  
 *  Explanation: This module is responsible for reading data
 *  from sensors installed on the GAS sensor board
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

float COsense()
{
  float coVal=0;
  //SensorGasv20.ON();
  RTC.ON();
  SensorGasv20.configureSensor(SENS_SOCKET4CO, GAIN_CO, RESISTOR_CO);
  SensorGasv20.setSensorMode(SENS_ON, SENS_SOCKET4CO);
  delay(DELAYCO); 

  // Faccio Media di 20 valori
  for (int i=0; i<10; i++)
  {
    coVal=coVal+SensorGasv20.readValue(SENS_SOCKET4CO);
  }
  coVal=coVal/10;
  //USB.print(F("CO: "));
  //USB.print(coVal);
  //USB.print(F(" V - "));
  coVal=SensorGasv20.calculateResistance(SENS_SOCKET4CO, coVal, GAIN_CO, RESISTOR_CO);

  //USB.print(F("CO: "));
  //USB.print(coVal);
  //USB.println(F(" KOHM"));
  SensorGasv20.setSensorMode(SENS_OFF, SENS_SOCKET4CO);
  RTC.OFF();
  //coVal=coVal/(80*3);
  coVal=coVal/RESISTOR_R0CO;
  //SensorGasv20.OFF();
  return coVal;

}

float CO2sense()
{

  float co2Val=0;
  // Configure the CO2 sensor socket
  // SensorGasv20.ON();
  RTC.ON();
  SensorGasv20.configureSensor(SENS_CO2, GAIN_CO2);
  SensorGasv20.setSensorMode(SENS_ON, SENS_CO2);
  delay(DELAYCO2); 
  for (int i=0; i<10; i++)
  {
    co2Val+=SensorGasv20.readValue(SENS_CO2);
  }
  co2Val=co2Val/10;
  //USB.print(F("CO2: "));
  //USB.print(co2Val);
  //USB.println(F(" V"));
  SensorGasv20.setSensorMode(SENS_OFF, SENS_CO2);
  RTC.OFF();
  //SensorGasv20.OFF();
  return VOLTAGE_CO2-co2Val;


}
float tempsense()
{

  //SensorGasv20.ON();
  //RTC.ON();
  int temperatureVal=0;
  delay(DELAYTEMP); 

  for (int i=0; i<20; i++)
  {
    temperatureVal+= SensorGasv20.readValue(SENS_TEMPERATURE);
  }
  temperatureVal=temperatureVal/20;
  //USB.print(F("T: "));
  //USB.print(temperatureVal);
  //USB.println(F("°C"));
  RTC.OFF();
  // SensorGasv20.OFF();
  return temperatureVal;

}

float O3sense()
{

  float socket2BVal=0;
  //SensorGasv20.ON();
  RTC.ON();
  SensorGasv20.configureSensor(SENS_SOCKET2B, GAIN_O3, RESISTOR_O3);
  SensorGasv20.setSensorMode(SENS_ON, SENS_SOCKET2B);
  delay(DELAYO3);

  for (int i=0; i<20; i++)
  {
    socket2BVal+=SensorGasv20.readValue(SENS_SOCKET2B);
  }
  socket2BVal=socket2BVal/20;
  //USB.print(F("O3: "));
  //USB.print(socket2BVal);
  //USB.print(F(" V - "));
  socket2BVal=SensorGasv20.calculateResistance(SENS_SOCKET2B, socket2BVal, GAIN_O3, RESISTOR_O3);

  //USB.print(F("O3: "));
  //USB.print(socket2BVal);
  //USB.println(F(" KOHM"));
  socket2BVal=socket2BVal/2333;
  SensorGasv20.setSensorMode(SENS_OFF, SENS_SOCKET2B);
  //RTC.OFF();
  //SensorGasv20.OFF();
  return socket2BVal;

}

float VOCsense()
{
  float socket2BVal=0;
  //SensorGasv20.ON();
  //RTC.ON();
  SensorGasv20.configureSensor(SENS_SOCKET2B, GAIN_VOC, RESISTOR_VOC);
  SensorGasv20.setSensorMode(SENS_ON, SENS_SOCKET2B);
  delay(DELAYVOC);

  for (int i=0; i<20; i++)
  {
    socket2BVal+=SensorGasv20.readValue(SENS_SOCKET2B);
  }
  socket2BVal=socket2BVal/20;
  //USB.print(F("VOC: "));
  //USB.print(socket2BVal);
  //USB.print(F(" V - "));
  socket2BVal=SensorGasv20.calculateResistance(SENS_SOCKET2B, socket2BVal, GAIN_VOC, RESISTOR_VOC);

  //USB.print(F("VOC: "));
  //USB.print(socket2BVal);
  //USB.println(F(" KOHM"));
  socket2BVal=socket2BVal/255;
  SensorGasv20.setSensorMode(SENS_OFF, SENS_SOCKET2B);
  //RTC.OFF();
  //SensorGasv20.OFF();
  return socket2BVal;

}

int HUMsense()
{
  float humidityVal=0.00;
  humidityVal = SensorGasv20.readValue(SENS_HUMIDITY);
  //USB.print(F("Humidity: "));
  //USB.print(humidityVal);
  //USB.println(F("%RH"));
  delay(1000);
  return humidityVal;
}
float NO2sense()
{
  float socket3BVal=0.00;
  // SensorGasv20.ON();
  RTC.ON();

  SensorGasv20.configureSensor(SENS_SOCKET3B, GAIN_NO2, RESISTOR_NO2);
  SensorGasv20.setSensorMode(SENS_ON, SENS_SOCKET3B);
  delay(DELAYNO2);

  for (int i=0; i<20; i++)
  {
    socket3BVal+=SensorGasv20.readValue(SENS_SOCKET3B);
  }
  socket3BVal=socket3BVal/20;
  //USB.print(F("NO2: "));
  //USB.print(socket3BVal);
  //USB.print(F(" V - "));
  socket3BVal=SensorGasv20.calculateResistance(SENS_SOCKET3B, socket3BVal, GAIN_NO2, RESISTOR_NO2);

  //USB.print(F("NO2: "));
  //USB.print(socket3BVal);
  //USB.println(F(" KOHM"));
  SensorGasv20.setSensorMode(SENS_OFF, SENS_SOCKET3B);
  RTC.OFF();
  //SensorGasv20.OFF();
  socket3BVal=socket3BVal/RESISTOR_R0NO2;
  return socket3BVal;

}


