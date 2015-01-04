using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.IO.Ports;
using System.Net;
//using System.IO.File;
using System.Windows.Forms.DataVisualization.Charting;
using System.Globalization;
using System.Threading;
using System.Data.SqlClient;
using System.IO;  //used to deal with the database

//campo from to
//ora nel grafico

namespace usbSensor
{
    //class that is in charge of teh gui of the program
    public partial class Form1 : Form
    {
        //public NotifyIcon notifyIcon = new NotifyIcon();
        public bool usbFixed = false;
        public bool parameterFixed = false;
        public String usbPort;
        public String[] parameters = {"Temperature", "CO", "CO2", "O3", "NO2" ,
                                     "ETemperature", "ECO", "ECO2", "EO3", "ENO2"};
        //public List<dateValue> readDataValue = new List<dateValue>();
        public dbHandler databaseManagement = new dbHandler();
        public int listBoxStartIndex = 0;
        public String URL = "xxxx";
        public usbMessage usbM = new usbMessage();
        public String timeGranularity;
        public String dayInterval;
        //the strings below are dedicated to SQL parameter in oading data
        //public String dateParameter = "";
        public String timeParameter = "";
        public DateTime dayStart;
        public int toAdd; //span hours

        public Form1()
        {
            InitializeComponent();
            //in this way the background worker tells to the gui when to update the chart
            backgroundWorker1.WorkerReportsProgress = true;
        }

        private void Form1_Load(object sender, EventArgs e)
        {

        }

        /*
         * FORM MANAGEMENT
         */

        //functions to put the program in the notify area
        private void button2_Click(object sender, EventArgs e)
        {
            notifyIcon1.Visible = true;
            notifyIcon1.ShowBalloonTip(3000);
            this.ShowInTaskbar = false;
            this.Hide();
        }

        //function to load the program from the notify area
        private void notifyIcon1_MouseDoubleClick(object sender, MouseEventArgs e)
        {
            this.WindowState = FormWindowState.Normal;
            this.ShowInTaskbar = true;
            notifyIcon1.Visible = false;
            this.Show();
        }

        //select the USB port
        private void comboBox1_SelectedIndexChanged(object sender, EventArgs e)
        {
            usbPort = comboBox1.SelectedItem.ToString();
            System.Diagnostics.Debug.Write(usbPort);
            usbFixed = true;
        }

        //shows the aggregate AQI 
        private void button1_Click(object sender, EventArgs e)
        {
            Form2 form2 = new Form2();
            form2.Show();
            //form2.chart1_Add(usbM, DateTime.Now.ToString("yyyy/MM/dd"));
        }

        //close the application
        private void close_Click(object sender, EventArgs e)
        {
            Application.Exit();
        }

        //select the time span to compute the average
        private void comboBox3_SelectedIndexChanged(object sender, EventArgs e)
        {
            timeGranularity = comboBox3.SelectedItem.ToString();

            if (timeGranularity.Equals("30 minutes"))
            {
                timeParameter = "";
                toAdd = 0;
            }
            if (timeGranularity.Equals("2 hours"))
            {
                toAdd = 2;
                timeParameter = "2";
            }
            if (timeGranularity.Equals("4 hours"))
            {
                toAdd = 4;
                timeParameter = "4";
            }
            if (timeGranularity.Equals("8 hours"))
            {
                toAdd = 8;
                timeParameter = "8";
            }
            if (timeGranularity.Equals("12 hours"))
            {
                toAdd = 12;
                timeParameter = "12";
            }
            if (timeGranularity.Equals("24 hours"))
            {
                toAdd = 24;
                timeParameter = "24";
            }

            System.Diagnostics.Debug.Write(timeGranularity + "\t" + toAdd + "\n\n");

        }
        
        /*
         * END FORM MANAGEMENT
         */

        /*
         * THESE ARE THE FUNCTIONS USED TO MANAGE THE CHARTS
         */

        /*
         * global function to add points in the various charts
         */
        public void chartAdd(double value, DateTime date, String param) 
        {
            if (param.Equals("InternalTemperature") || param.Equals("ExternalTemperature"))
                tempAdd(value, date, param);
            //if (param.Equals("InternalHumidity") || param.Equals("ExternalHumidity")) ;
            //    humAdd(value, date, param);
            if (param.Equals("InternalCO") || param.Equals("ExternalCO"))
                COAdd(value, date, param);
            if (param.Equals("InternalCO2") || param.Equals("ExternalCO2"))
                CO2Add(value, date, param);
            if (param.Equals("InternalNO2") || param.Equals("ExternalNO2"))
                NO2Add(value, date, param);
            if (param.Equals("InternalO3") || param.Equals("ExternalO3"))
                O3Add(value, date, param);
            //if (param.Equals("InternalVOC") || param.Equals("ExternalVOC"))
              //  VOCAdd(value, date, param);
        }

        private void tempAdd(double value, DateTime date, String param) {
           Series s = this.temperature.Series[param];
           this.temperature.Series[param].XValueType = ChartValueType.DateTime;
           temperature.ChartAreas[0].AxisX.LabelStyle.Format = "dd/MM/yyyy HH:mm";
           //String format = "dd/MM/yyyy HH:mm";
           //DateTime d; // = Convert.ToDateTime(date);
           //DateTime.TryParseExact(date, format, null, DateTimeStyles.None, out d);
           System.Diagnostics.Debug.Write(date.ToString("dd/MM/yyyy HH:mm") + "\n");
           s.Points.AddXY(date/*.ToOADate()*/, value);
           s.Sort(PointSortOrder.Ascending, "X");
        }

        //private void humAdd(double value, String date, String param) {
        //   Series s = this.Humidity.Series[param];
        //   s.Points.AddXY(date, value);
        //}

        private void COAdd(double value, DateTime date, String param) {
           Series s = this.CO.Series[param];
           this.CO.Series[param].XValueType = ChartValueType.DateTime;
           CO.ChartAreas[0].AxisX.LabelStyle.Format = "dd/MM/yyyy HH:mm";
           //String format = "dd/MM/yyyy HH:mm";
           //DateTime d;// = Convert.ToDateTime(date);
           //DateTime.TryParseExact(date, format, null, DateTimeStyles.None, out d);
           //System.Diagnostics.Debug.Write(d.ToString("dd/MM/yyyy HH:mm") + "\n\t" + date + "\n\n");
           s.Points.AddXY(date, value);
           s.Sort(PointSortOrder.Ascending, "X");
        }

        private void CO2Add(double value, DateTime date, String param) {
           Series s = this.CO2.Series[param];
           this.CO2.Series[param].XValueType = ChartValueType.DateTime;
           CO2.ChartAreas[0].AxisX.LabelStyle.Format = "dd/MM/yyyy HH:mm";
           //String format = "dd/MM/yyyy HH:mm";
           //DateTime d;// = Convert.ToDateTime(date);
           //DateTime.TryParseExact(date, format, null, DateTimeStyles.None, out d);
           //System.Diagnostics.Debug.Write(d.ToString("dd/MM/yyyy HH:mm") + "\n\t" + date + "\n\n");
           s.Points.AddXY(date, value);
           s.Sort(PointSortOrder.Ascending, "X");
        }

        private void O3Add(double value, DateTime date, String param) {
           Series s = this.O3.Series[param];
           this.O3.Series[param].XValueType = ChartValueType.DateTime;
           O3.ChartAreas[0].AxisX.LabelStyle.Format = "dd/MM/yyyy HH:mm";
           //String format = "dd/MM/yyyy HH:mm";
           //DateTime d;// = Convert.ToDateTime(date);
           //DateTime.TryParseExact(date, format, null, DateTimeStyles.None, out d);
           //System.Diagnostics.Debug.Write(d.ToString("dd/MM/yyyy HH:mm") + "\n\t" + date + "\n\n");
           s.Points.AddXY(date, value);
           s.Sort(PointSortOrder.Ascending, "X");
        }

        private void NO2Add(double value, DateTime date, String param) {
           Series s = this.NO2.Series[param];
           this.NO2.Series[param].XValueType = ChartValueType.DateTime;
           NO2.ChartAreas[0].AxisX.LabelStyle.Format = "dd/MM/yyyy HH:mm";
           //String format = "dd/MM/yyyy HH:mm";
           //DateTime d;// = Convert.ToDateTime(date);
           //DateTime.TryParseExact(date, format, null, DateTimeStyles.None, out d);
           //System.Diagnostics.Debug.Write(d.ToString("dd/MM/yyyy HH:mm") + "\n\t" + date + "\n\n");
           s.Points.AddXY(date, value);
           s.Sort(PointSortOrder.Ascending, "X");
        }

        /*private void VOCAdd(double value, String date, String param) {
           Series s = this.VOC.Series[param];
           s.Points.AddXY(date, value);
        }*/
        //clear all the data in the chart
        private void clearChart()
        {
            foreach (var series in temperature.Series)
            {
                series.Points.Clear();
            }

            foreach (var series in CO.Series)
            {
                series.Points.Clear();
            }

            foreach (var series in CO2.Series)
            {
                series.Points.Clear();
            }

            foreach (var series in O3.Series)
            {
                series.Points.Clear();
            }

            foreach (var series in NO2.Series)
            {
                series.Points.Clear();
            }
        }

        /*
         * END CHART MANAGEMENT FUNCTIONS
         */

        /*
         * DB MANAGEMENT
         */

        /*
         * In saving and loading we store/load all the data received
         */
        //save the data read in a database
        public void storeDb(String param, double value, String date)
        {
            //build of the sql command to insert data
            string commandText = "INSERT INTO " + param + " ( [Value], [DateTime], [ID])" +
                                "VALUES (@Value, @DateTime, @ID);";
            string maxIDquery = "SELECT ID FROM " + param;
            databaseManagement.createConnection();
            SqlCommand sqlCmd = new SqlCommand(commandText, databaseManagement.myConnection);
            int i = 0;
            
            //before adding a new value we need to know which is the ID to be inserted
            SqlDataReader myReader = databaseManagement.dbCommand(maxIDquery);
            DataTable dt = new DataTable();
            dt.Load(myReader);
            
            /*
             * to compute the ID a possible choice would be to count the rows and 
             * set the id to NumberofRows+1, I didn't make this choice because we
             * may have some deletions in our database, thus the ordering o the key
             * may not be respected anymore
             */
            if (dt.Rows.Count == 0)
                i = 1;
            else
            {
                int maxAccountLevel = int.MinValue;
                foreach (DataRow dr in dt.Rows)
                {
                    int accountLevel = int.Parse(dr["ID"].ToString());
                    maxAccountLevel = Math.Max(maxAccountLevel, accountLevel);
                }
                i = maxAccountLevel;
                i++;
            }
            System.Diagnostics.Debug.Write("\nindex: " + i + "\n");

            //set the type of the parameters to add
            sqlCmd.Parameters.Add("@Value", SqlDbType.Float);
            sqlCmd.Parameters.Add("@DateTime", SqlDbType.DateTime);
            sqlCmd.Parameters.Add("@ID", SqlDbType.NChar);

            value = Math.Round(value, 4);

            //set the parameters to add
            sqlCmd.Parameters["@Value"].Value = (float)value;
            sqlCmd.Parameters["@DateTime"].Value = Convert.ToDateTime(date);
            sqlCmd.Parameters["@ID"].Value = i;

            //execute the query
            sqlCmd.ExecuteNonQuery();
        }

        //loads all the data stored in the db and put them on the chart
        private void loadData_Click(object sender, EventArgs e)
        {
            //clear the chart
            clearChart();

            //create the connection to the db
            bool res = databaseManagement.createConnection();
            if(res == false)
            {
                textBox2.Text += "\nError connecting to the db, retry!\n";
                return;
            }

            //date parameters to build if a time span is set
            DateTime start, to;
            String dateParameter = "";
            Thread.CurrentThread.CurrentCulture = new CultureInfo("en");
            
            /*
             * set the various date and time if necessary, both date
             * of start and final date have to be set
             */
            if (!dayS.Text.Equals("day"))
            {
                int day, month, year;
                try
                {
                    day = Convert.ToInt32(dayS.Text);
                    month = Convert.ToInt32(monthS.Text);
                    year = Convert.ToInt32(yearS.Text);
                }

                catch (Exception)
                {
                    textBox2.Text += "\nerror in the format: " + dayS +
                        " " + monthS + " " + yearS + "\n" ;
                    return;
                }

                //construct the date from which start
                start = new DateTime(year, month, day);
                
                try
                {
                    day = Convert.ToInt32(dayT.Text);
                    month = Convert.ToInt32(monthT.Text);
                    year = Convert.ToInt32(yearT.Text);
                }
                catch (Exception)
                {
                    textBox2.Text += "\nerror in the format\n";
                    return;
                }

                //construct the end date
                to = new DateTime(year, month, day);

                dateParameter = "date set";

                //System.Diagnostics.Debug.Write("date set " + to.ToString("dd/MM/yyyy") + "\n");
            }

            else
            {
                
                start = DateTime.Now;
                to = DateTime.Now;
            }

            /*
             * this operation is needed since we need to reach the 00:00 of the next day
             * since the from operator includes the day
             */
                    
            to = to.AddDays(1);

            //System.Diagnostics.Debug.Write("to date: " + to.ToString("dd-MM-yyyy") + "\n");


            /*
             * now a query for each parameter has to be built 
             */
            foreach (String param in parameters)
            {
                List<String> cmd = new List<String>(); //clause to be used to select a time interval
                dayStart = start;
                dayInterval = dayStart.ToString("dd-MM-yyyy");
                
                /*
                 * build a query for the case in which a time parameter and
                 * a date parameter have been specified
                 */
                if (!timeParameter.Equals("") && !dateParameter.Equals(""))
                {
                    
                    //System.Diagnostics.Debug.Write("\n\n\time parameter and date selected\n\n");
                    int i = 0;
                    
                    while (!to.ToString("dd-MM-yyyy").Equals(dayInterval))
                    {
                        while (i < 24)
                        {
                            int j = (i + toAdd) % 24;
                            if(j == 0)
                                dayInterval = dayStart.AddDays(1).ToString("dd-MM-yyyy");
                            String s = "SELECT AVG(Value) AS Value, MIN(DateTime) AS DateTime" + 
                                " FROM " + param +
                                " WHERE DateTime >= CONVERT(datetime, '" + dayStart.ToString("dd-MM-yyyy")
                                + " " + i + ":00') AND DateTime < CONVERT(datetime, '" + dayInterval
                                + " " + j + ":00') ORDER BY DateTime;";
                            //System.Diagnostics.Debug.Write("\n\n" + s + "\t\t" + toAdd + "\n\n");
                            cmd.Add(s);
                            i = i + toAdd;
                        }
                        DateTime d = dayStart.AddDays(1);
                        dayStart = d;
                        //System.Diagnostics.Debug.Write(dayStart.ToString("yyyy-MM-dd HH:mm\n"));
                        i = 0;
                    }
                }

                else
                    /*
                     * build a query in the case in which only a date parameter is specified 
                     * not a time parameter on which compute the average
                     */
                    if (!dateParameter.Equals(""))
                    {
                        String endString = to.ToString("dd-MM-yyyy");
                        //System.Diagnostics.Debug.Write("\n\ndate selected " + endString + "\n\n");
                        String l = "SELECT Value, DateTime "
                            + "FROM " + param + " WHERE DateTime" +
                            ">= CONVERT(datetime, '" + dayInterval + "') AND DateTime < CONVERT(datetime, '" +
                            endString + "') ORDER BY DateTime;";
                        cmd.Add(l);
                    }
                    else
                        /*case in which no parameter is specified*/
                        cmd.Add("SELECT * FROM " + param + " ORDER BY DateTime;");

                /*
                 * now that we have all the various strings for each date and/or time 
                 * interval we have to execute them
                 */
                foreach (String tmpCmd in cmd)
                {
                    SqlDataReader myReader = databaseManagement.dbCommand(tmpCmd);
                    DataTable dT = new DataTable();
                    dT.Load(myReader);

                    //System.Diagnostics.Debug.Write(dT.Rows.Count + "\n");

                    //foreach data in rows add the point to the chart
                    if (dT.Rows.Count > 0)
                    {
                        foreach (DataRow dr in dT.Rows)
                        {
                            String tmpVal = dr["Value"].ToString();
                            String tmpDate = dr["DateTime"].ToString();

                            if (tmpVal.Equals("") || tmpDate.Equals(""))
                            {
                                System.Diagnostics.Debug.Write("empty field");
                                break;
                            }

                            DateTime dt = Convert.ToDateTime(tmpDate);

                            tmpDate = dt.ToString("dd/MM/yyyy HH:mm");
                            double oleData = dt.ToOADate();
                            //System.Diagnostics.Debug.Write("SqlDate: " + tmpDate + "\t" + oleData + "\n");
                            
                            //to use always the same notation
                            String val = tmpVal.Replace(',', '.');
                            double dVal = double.Parse(val, System.Globalization.CultureInfo.CurrentCulture);
                            if (param.StartsWith("E"))
                            {
                                String tmp = param.Replace("E", "External");
                                System.Diagnostics.Debug.Write("External parameter " + param + "\t" + tmp + "\n");
                                chartAdd(dVal, dt, tmp);
                            }
                            else
                                chartAdd(dVal, dt, "Internal" + param);
                        }
                    }
                }
            }
            databaseManagement.closeConnection();

        }

        /*
         * END DB MANAGEMENT
         */

        /*
         * BEGIN BACKGROUND_WORKER1
         * Part related to the background worker that is in charge of reading sensor data
         */

        //job of the background worker
        private void backgroundWorker1_DoWork(object sender, DoWorkEventArgs e)
        {
            Thread.CurrentThread.CurrentCulture = new CultureInfo("en");
            BackgroundWorker worker = sender as BackgroundWorker;
            //char[] delimiter = { ' ' };
            readData readD = new readData(usbPort);
            while (true)
            {
                //read the string and extract the data
                String s = readD.readValue();

                //System.Diagnostics.Debug.Write("received String: " + s + "\n" );
                //consideredParameter = words[0];

                //check if the received message is from the external or internal node
                if(s.Contains("E:") || s.StartsWith("I:"))

                    //the backgroundworker reports the progress to the form
                    worker.ReportProgress(0, s);
                s = "";
            }
        }

        /*
         * when the background worker reports a progress, an event progress changed is
         * risen, here we manage it
         */
        private void backgroundWorker1_ProgressChanged(object sender, ProgressChangedEventArgs e)
        {
            //convert to string the parameters passed by the reportprogress
            String parameters = e.UserState.ToString();
            //usbMessage usbM = new usbMessage();

            /*
             * we retrieve now the date and the time even if this causes
             * more computations to split the string because in this way
             * we're closer to the effective time in which the read happens
             */
            DateTime now = DateTime.Now;
            String date = now.ToString("dd/MM/yyyy HH:mm");

            usbM.buildMessage(parameters);

            if (usbM.getType().Equals("External"))
            {
                
                /*
                 * Now it's time to do the GET requests to the server
                 */
                //retrieve the integers that form the date
                int year = usbM.Year;
                int month = usbM.Month;
                int day = usbM.Day;
                int hour = usbM.Hour;
                int minute = usbM.Minute;
                int second = usbM.Second;

                DateTime dt = new DateTime(year, month, day, hour, minute, second);

                date = dt.ToString("yyyy/MM/dd HH:mm");

                //add the various data to the chart
                chartAdd(usbM.ETemperature, dt, "ExternalTemperature");
                chartAdd(usbM.ECO, dt, "ExternalCO");
                chartAdd(usbM.ECO2, dt, "ExternalCO2");
                chartAdd(usbM.EO3, dt, "ExternalO3");
                chartAdd(usbM.ENO2, dt, "ExternalNO2");                
                String response;
                WebRequest wrGETURL;
                String urlParam = URL + "/xxxx.php?v=" + usbM.nodeID + "|" + usbM.EBattery
                    + "|" + usbM.ETemperature + "|" + usbM.ECO + "|" + usbM.ECO2 + "|" + usbM.ENO2 + "|"
                    + usbM.EO3 + "|" + usbM.EVOC + "|" + usbM.EHumidity + "|" + year + "|" +
                    month + "|" + day + "|" + hour + "|" + minute + "|" + second;
                try
                {
                    wrGETURL = WebRequest.Create(urlParam);
                    response = wrGETURL.GetResponse().ToString();
                    //this.textBox3.Text = response;
                    //System.Diagnostics.Debug.Write(response);
                    
                    //load all the previous data stored in the file
                    if (File.Exists(".\\saveFile.txt"))
                    {
                        String[] listString = File.ReadAllLines(".\\saveFile.txt");
                        foreach(String s in listString)
                        {
                            wrGETURL = WebRequest.Create(urlParam);
                            //response = wrGETURL.GetResponse().ToString();
                            //System.Diagnostics.Debug.Write(response);
                        }
                        File.Delete(".\\saveFile.txt");
                    }

                }
                catch (System.Net.WebException)
                {
                    //in case of exception write the content into a local file
                    File.AppendAllText(".\\saveFile.txt", urlParam);
                    System.Diagnostics.Debug.Write("saving to file\n");
                }
                storeDb("ETemperature", usbM.ETemperature, date);
                storeDb("EHumidity", usbM.EHumidity, date);
                storeDb("ECO", usbM.ECO, date);
                storeDb("ECO2", usbM.ECO2, date);
                storeDb("EO3", usbM.EO3, date);
                storeDb("ENO2", usbM.ENO2, date);
                storeDb("EVOC", usbM.EVOC, date);

            }
            //insert the date and value in the chart
            else
            {
                chartAdd(usbM.ITemperature, now, "InternalTemperature");
                //chartAdd(usbM.EHumidity, date, "ExternalHumidity");
                //chartAdd(usbM.IHumidity, date, "InternalHumidity");
                chartAdd(usbM.ICO, now, "InternalCO");

                chartAdd(usbM.ICO2, now, "InternalCO2");

                chartAdd(usbM.IO3, now, "InternalO3");

                chartAdd(usbM.INO2, now, "InternalNO2");
                //chartAdd(usbM.EVOC, date, "ExternalVOC");
                //chartAdd(usbM.IVOC, date, "InternalVOC");            

                date = now.ToString("yyyy/MM/dd HH:mm");

                /*
                 * now the external data have to be sent to an external server while the internal ones
                 * have to be stored to a database
                 */
                storeDb("Temperature", usbM.ITemperature, date);
                storeDb("Humidity", usbM.IHumidity, date);
                storeDb("CO", usbM.ICO, date);
                storeDb("CO2", usbM.ICO2, date);
                storeDb("O3", usbM.IO3, date);
                storeDb("NO2", usbM.INO2, date);
                storeDb("VOC", usbM.IVOC, date);
            }
        }

        //starts the background worker
        private void start_Click(object sender, EventArgs e)
        {
            if (!usbFixed)
            {
                this.textBox2.Text = "Select an USB port";
            }
            else
            {
                this.textBox2.Text = "Background worker running...\n";
                backgroundWorker1.RunWorkerAsync();
            }
        }
        /*
         * END OF BACKGROUND WORKER PART
         */
    };

    /*
     * this class is used to do the parsing of the usb message sent by the internal node, 
     * in this way it becomes simpler to retrieve the various values.
     * 
     * NOTE: in the following E stands for extenral, these are the parameters related to
     * the external node, I stands for internal
     * 
     * This is the format of a xbeemessage:
     * "MAC ADDRESS#INIT#NUMBERofMSG#TYPEofMSG#TYPEofNODE: NodeID|Battery|Tmp|CO|CO2|NO2|O3|VOC|HUM"
     * <=>€#382543503#EXTNode#2#STR:E: 1|89|20|8.2159|1.2187|0.0445|0.0066|0.0000|-25|
     * I: 0|94|22|7.5131|1.5793|0.0364|0.0049|0.0000|-25|
     */
    public class usbMessage
    {
        char[] delimiters = { '|', ' ', }; //these are the possible delimiters

        public int nodeID;
        public int EBattery;
        public double ETemperature { get; set; }
        public double EHumidity { get; set; }
        public double EVOC { get; set; }
        public double ECO2 { get; set; }
        public double ECO { get; set; }
        public double ENO2 { get; set; }
        public double EO3 { get; set; }
        public int Year;
        public int Month;
        public int Day;
        public int Hour;
        public int Minute;
        public int Second;
        public String type = "";

        public int IBattery;
        public double ITemperature { get; set; }
        public double IHumidity { get; set; }
        public double IVOC { get; set; }
        public double ICO2 { get; set; }
        public double ICO { get; set; }
        public double INO2 { get; set; }
        public double IO3 { get; set; }

        //from the received string tries to set all the parameters of the message class TODO
        public void buildMessage(String msg)
        {
            double temp;
            //set the culture info to english
            Thread.CurrentThread.CurrentCulture = new CultureInfo("en");

            String[] values;

            /*
             * search if there is the 'E' letter in the first string, 
             * this means message from the external node sender correctly received
             */
            values = msg.Split(delimiters);
            
            if (msg.Contains('E'))
            {
                this.type = "External";
                //convert the various strings to double
                nodeID = Convert.ToInt32(values[1]);
                EBattery = Convert.ToInt32(values[2]);
                ETemperature = double.Parse(values[3], System.Globalization.CultureInfo.CurrentCulture);
                temp = double.Parse(values[4], System.Globalization.CultureInfo.CurrentCulture);
                ECO = PPMconvertCO(temp);
                temp = double.Parse(values[5], System.Globalization.CultureInfo.CurrentCulture);
                ECO2 = PPMconvertCO2(temp);
                temp = double.Parse(values[6], System.Globalization.CultureInfo.CurrentCulture);
                ENO2 = PPMconvertNO2(temp);
                temp = double.Parse(values[7], System.Globalization.CultureInfo.CurrentCulture);
                EO3 = PPMconvertO3(temp);
                temp = double.Parse(values[8], System.Globalization.CultureInfo.CurrentCulture);
                EVOC = PPMconvertVOC(temp);
                EHumidity = double.Parse(values[9], System.Globalization.CultureInfo.CurrentCulture);
                String year = "20" + values[10];
                Year = int.Parse(year);
                Month = int.Parse(values[11]);
                Day = int.Parse(values[12]);
                Hour = int.Parse(values[13]);
                Minute = int.Parse(values[14]);
                Second = int.Parse(values[15]);
                System.Diagnostics.Debug.Write( Year + " " + Month +
                    " " + Day + " " + Hour + " " + Minute + " " + Second);
            }
            else
            {
                this.type = "Internal";
                IBattery = Convert.ToInt32(values[2]);
                //set the internal parameters
                ITemperature = double.Parse(values[3], System.Globalization.CultureInfo.CurrentCulture);
                temp = double.Parse(values[4], System.Globalization.CultureInfo.CurrentCulture);
                ICO = PPMconvertCO(temp);
                temp = double.Parse(values[5], System.Globalization.CultureInfo.CurrentCulture);
                ICO2 = PPMconvertCO2(temp);
                temp = double.Parse(values[6], System.Globalization.CultureInfo.CurrentCulture);
                INO2 = PPMconvertNO2(temp);
                temp = double.Parse(values[7], System.Globalization.CultureInfo.CurrentCulture);
                IO3 = PPMconvertO3(temp);
                temp = double.Parse(values[8], System.Globalization.CultureInfo.CurrentCulture);
                IVOC = PPMconvertVOC(temp);
                IHumidity = double.Parse(values[9], System.Globalization.CultureInfo.CurrentCulture);
            }
            /*System.Diagnostics.Debug.Write("External parameters\n\tET: " + ETemperature +
                "\n\tEH: " + EHumidity + "\n\tECO: " + ECO + "\n\tECO2: " + ECO2 + "\n\tENO2: " +
                ENO2 + "\n\tEO3: " + EO3 + "\nInternal parameters\n\tIT: " + ITemperature +
                "\n\tIH: " + IHumidity + "\n\tICO: " + ICO + "\n\tICO2: " + ICO2 + "\n\tINO2: " +
                INO2 + "\n\tIO3: " + IO3);*/
        }

        public String getType() 
        {
            return type;
        }

        /*
         * This functions convert the read value into PPM
         */
        public double PPMconvertCO(double value)
        {
            value = Math.Log10(value);
            value = (-0.855 * value) + 1.9898;
            value = Math.Round(Math.Pow(10, value), 4);
            return value;
        }

        public double PPMconvertCO2(double value)
        {
            value = value * 100;
            value = (0.0155 * value) + 2.544;
            value = Math.Round(Math.Pow(10, value), 4);
            return value;
        }

        public double PPMconvertO3(double value)
        {
            value = Math.Log10(value);
            value = (0.854 * value) + 2.04;
            value = Math.Round(Math.Pow(10, value), 4);
            return value;
        }

        public double PPMconvertNO2(double value)
        {
            value = Math.Log10(value);
            value = (0.568 * value) - 1.52;
            value = Math.Round(Math.Pow(10, value), 4);
            return value;
        }

        public double PPMconvertVOC(double value)
        {
            if (value == 0)
                return 0;
            else
            {
                value = Math.Log10(value);
                value = (-1.713 * value) + 3.417;
                value = Math.Round(Math.Pow(10, value), 4);
                return value;
            }
        }

    }
    //class that is in charge of read the data from the sensor
    public class readData {
        
        public List<String> valueRead = new List<String>();
        public SerialPort usbSensorPort;
        
        //constructor of the class
        public readData(String port)
        {
            //allocate the serial port for the usb sensor board
            usbSensorPort = new SerialPort(port, 115200);
            usbSensorPort.Open();
        }

        //reads a value from usb 
        public String readValue() 
        {
            try
            {
                String s = usbSensorPort.ReadLine();
                //write string to stdout 
                System.Diagnostics.Debug.Write("\n\tUSBreceived String" + s + "\n\n");
                return s;
            }

            catch (InvalidOperationException) 
            {
                System.Diagnostics.Debug.Write("Invalid operation exception");
            }

            return "NaN";
        }

        //parse the string and retrieve the datum
        public String parseString(String s)
        {
            char[] delimiter = { ' ', 'C' };
            String[] words = s.Split(delimiter);

            //System.Diagnostics.Debug.Write("Strin" + words[1]+ "\n");

            if (words.Length < 2)

                return "null";

            try
            {
                //retrieve the double
                String t = words[1];
                //System.Diagnostics.Debug.Write(t);
                return t;
            }

            catch (FormatException)
            {
                System.Diagnostics.Debug.Write("format exception");
            }

            catch (OverflowException)
            {
                System.Diagnostics.Debug.Write("Overflow exception");
            }
            return "null";
        }
    };
    
    public class dbHandler
    {
        public String user = "";
        public String password = "";
        public String serverUrl = "";
        public String dbName = "inDoorAirQuality";
        public SqlConnection myConnection;
        
        //create a new sql connection to a database
        public bool createConnection()
        {
            myConnection = new SqlConnection("user id=" + user +
                ";password=" + password + ";server=" + serverUrl + ";Trusted_Connection=yes"
                + ";database=" + dbName + ";connection timeout=30");
            //myConnection = new SqlConnection("user id=salvo-PC\\Antonio;password=;server= ")
            try
            {
                myConnection.Open();
            }
            catch(Exception)
            {
                System.Diagnostics.Debug.Write("error in the connection");
                return false;
            }
            if (myConnection == null) 
            {
                System.Diagnostics.Debug.Write("error in the connection2");
                return false;
            }
            System.Diagnostics.Debug.Write("Connection correctly executed");
            return true;
        }
        
        //commands the database
        /*
         * cmd is the string that contains the sql query to do
         * c is a char: 'r' for read, 'i' for insert
         */
        public SqlDataReader dbCommand(String cmd)
        {
            //createConnection();
            SqlDataReader myReader = null;
            SqlCommand myCommand = new SqlCommand();
            myCommand.Connection = myConnection;
            
            myCommand.CommandText = cmd;
            myReader = myCommand.ExecuteReader();
            return myReader;
        }

        //close the connection to the db
        public void closeConnection()
        {
            myConnection.Close();
        }
    }
}