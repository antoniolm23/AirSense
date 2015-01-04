/*  
 *  ------ USENSE sdWRITE MODULE -------- 
 *  
 *  Explanation: This module deals with the management of the SD card ,
 *  there is a function to check the file for writing in the queue, 
 *  to delete the file after transmission
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

//char* filename=FILENAME;
int deletefile()
{
  SD.OFF();
  SD.ON();
  int ret=0;
  if(SD.del(FILENAME))
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
  SD.ON();
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
  //SD.ON();
  USB.println(F("Show file:"));      
  USB.println(F("-------------------"));
  USB.println(SD.catln(filename, 0, SD.numln(filename) ));
  USB.println(F("-------------------"));
  //SD.OFF();
}

/*
 * this function returns the length of the string
 * the parameter passed is a offset that states from
 * where starting the search 
 * By hypothesis the file will be written as follows: 
 packet date & */

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


