/*  
 *  --[SC_1] - Reading the MCP9700A Temperature Sensor on Smart Cities board-- 
 *  
 *  Explanation: Turn on the sensor every second, taking a measurement and printing
 *               its result through the USB port.
 *  
 *  Copyright (C) 2012 Libelium Comunicaciones Distribuidas S.L. 
 *  http://www.libelium.com 
 *  
 *  This program is free software: you can redistribute it and/or modify 
 *  it under the terms of the GNU General Public License as published by 
 *  the Free Software Foundation, either version 3 of the License, or 
 *  (at your option) any later version. 
 *  
 *  This program is distributed in the hope that it will be useful, 
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of 
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the 
 *  GNU General Public License for more details. 
 *  
 *  You should have received a copy of the GNU General Public License 
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>. 
 *  
 *  Version:           0.1 
 *  Design:            David Gascón 
 *  Implementation:    Manuel Calahorra
 */

#include <WaspSensorCities.h>

char* filename="DATA.txt";
char* buffer = "E: 1|88|21|11.3164|0.9812|0.1609|0.0101|0.0000|-25|11|4|5|12|26|53  &\n E: 1|88|21|10.0448|0.9338|0.1660|0.0100|0.0000|-25|11|4|5|12|30|7  &\n E: 1|88|21|10.0722|0.9054|0.1724|0.0101|0.0000|-25|11|4|5|12|33|22  &";
char buffer1[159];
int readline(int offset)
{
  USB.println("readline\n");
  
  SdFile file;
  SD.openFile(filename, &file, O_READ);
  
  int  last  = SD.indexOf(filename, "&", offset);
  SD.cat(filename, offset, last);
  
  //USB.println(SD.buffer);
  
  SD.closeFile(&file);
  
  return last;
}

int deletefile()
{
  SD.OFF();
  SD.ON();
  int ret=0;
  if(SD.del(filename))
  {
    ret=1;
  }
  else 
  {
    ret=0;
  }  
  return ret;

}

void writefile(char* sentence)
{

  if (SD.isFile(filename)==1)
  {

    if(SD.appendln(filename,sentence))  
    {
      USB.println(F("\nAppend ok"));
    }

    else 
    {
      USB.println(F("\nAppend error"));
    }


    // show file
    showFile();

  }

  else 
  {
    USB.println(F("file NOT exist"));  
    if(SD.create(filename))
    {
      if(SD.appendln(filename,sentence))  
      {
        USB.println(F("\nAppend ok"));
        showFile();
      }

      else 
      {
        USB.println(F("\nAppend error"));
      }

    }
    else
    {
      USB.println(F("file NOT create!!"));
    }
    
  }  

}
void showFile()
{
  // show file
  SD.ON();
  USB.println(F("Show file:"));      
  USB.println(F("-------------------"));
  USB.println(SD.catln(filename, 0, SD.numln(filename) ));
  USB.println(F("-------------------"));
  //SD.OFF();
}



// Variable to store the read value
float value;
char sValue[8];
void setup()
{
  deletefile();
  // Turn on the USB and print a start message
  USB.ON();
  SD.ON();
  //USB.println(F("start"));
  delay(100);

  // Turn on the sensor board
  SensorCities.ON();
  
  // Turn on the RTC
  RTC.ON();
  
}
 
void loop()
{
  SD.ON();
  // Part 1: Sensor reading
  // Turn on the sensor and wait for stabilization and response time
  int last = 0;
  int offset = 0;
  writefile(buffer);
  USB.printf("Lines: %d", SD.numln(filename));
  for(int i = 0; i < SD.numln(filename); i++) {
    USB.printf("last %d offset %d\n",last, offset);
    last = readline(offset);
    USB.printf("last %d offset %d\n",last, offset);
    //USB.println(SD.buffer);
    memcpy(buffer1, SD.buffer, 256);
    USB.println(buffer1);
    offset = offset + last + 1;
  }
  SD.OFF();
  delay(1000000);
}
