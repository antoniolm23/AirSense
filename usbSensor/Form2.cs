using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Windows.Forms.DataVisualization.Charting;
using System.Data.SqlClient;
using System.Threading;
using System.Globalization;

namespace usbSensor
{
    public partial class Form2 : Form
    {
        //db management
        public dbHandler databaseManagement = new dbHandler();
        public O3Breakpoint Ob;
        public COBreakpoint Cob = new COBreakpoint();
        public NO2Breakpoint Nob = new NO2Breakpoint();
        //gases breakpoint
        /*public double[] O3Breakpoint8 = { 0, 0.060, 0.076, 0.096, 0.116, 0.374 };
        public double[] COBreakpoint = { 0, 4.4, 4.5, 9.4, 9.5, 12.4, 12.5,
                                           15.4, 15.5, 30.4, 30.5, 40.4, 40.5, 50.4 };
        public double[] NO2Breakpoint = { 0, 53, 54, 100, 101, 360, 361,
                                            649, 650, 1249, 1250, 1649, 1650, 2049 };
        public int[] Aqi = { 0, 50, 51, 100, 101, 150, 151, 200, 201, 300, 301, 400, 401, 500 };
        */
        public Form2()
        {
            InitializeComponent();
            databaseManagement.createConnection();

            /*Internal AQI LABEL*/
            int internalAqi = computeInternalAQI();
            this.textBox1.Text = internalAqi.ToString();
            textBox1.ForeColor = Color.White;
            colorAndText(internalAqi, textBox1);
            int externalAqi = computeExternalAqi();
            label3.Text = externalAqi.ToString();
            label3.ForeColor = Color.White;
            colorAndText(externalAqi, label3);
            databaseManagement.closeConnection();
        }

        public void colorAndText(int Aqi, Label textBox1)
        {
            if (Aqi < 51)
            {
                textBox1.BackColor = Color.Green;
                textBox1.Text += " GOOD";
            }
            else
                if (Aqi < 101)
                {
                    textBox1.BackColor = Color.Yellow;
                    textBox1.Text += " MODERATE";
                }
                else
                    if (Aqi < 151)
                    {
                        textBox1.BackColor = Color.Orange;
                        textBox1.Text += " UNHEALTHY for sensitive groups";
                    }
                    else
                        if (Aqi < 201)
                        {
                            textBox1.BackColor = Color.Red;
                            textBox1.Text += " UNHEALTHY";
                        }
                        else
                            if (Aqi < 301)
                            {
                                textBox1.BackColor = Color.Purple;
                                textBox1.Text += " VERY UNHEALTHY";
                            }
                            else
                            {
                                textBox1.BackColor = Color.Maroon;
                                textBox1.Text += " HAZARDOUS";
                            }
        }

        //retrieve the index of the value before the considered one
        
        //retrieve the limits of O3, both numerical and of AQI indexes
        

        /*
         * Function that computes the average of the considered parameter
         * for the time considered by the AQI index
         */
        private double retrieveAVG(String param, DateTime now, int hoursToAdd)
        {
            Thread.CurrentThread.CurrentCulture = new CultureInfo("en");
            double dVal = 0;

            DateTime start = now.AddHours(hoursToAdd);
            //start = start.AddDays(-13);

            //now = now.AddDays(-12);

            //query
            String query = "SELECT AVG(Value) AS Value FROM " + param +
                                " WHERE DateTime >= CONVERT(datetime, '" +
                                start.ToString("dd-MM-yyyy HH:mm") + "') AND DateTime < CONVERT(datetime, '"
                                + now.ToString("dd-MM-yyyy HH:mm") + "'); ";
            SqlDataReader myReader = databaseManagement.dbCommand(query);
            DataTable dT = new DataTable();
            dT.Load(myReader);
            if (dT.Rows.Count > 0)
            {
                foreach (DataRow dr in dT.Rows)
                {
                    String tmpVal = dr["Value"].ToString();
                    if (tmpVal.Equals(""))
                        return 0;
                    //to use always the same notation
                    String val = tmpVal.Replace(',', '.');
                    dVal = double.Parse(val, System.Globalization.CultureInfo.CurrentCulture);
                }
            }

            System.Diagnostics.Debug.Write(dVal + "\n");

            return dVal;
        }

        /*Internal AQI*/
        //function to compute the actual AQI
        public int computeInternalAQI() 
        {
            double tmp;

            DateTime now = DateTime.Now;

            //AQI indexes
            int O3Index = 0;
            int COIndex = 0;
            int NO2Index = 0;

            //compute the various averages
            double AvgO3 = retrieveAVG("O3", now, -8);
            AvgO3 = Math.Round(AvgO3, 3);
            Ob = new O3Breakpoint(AvgO3);
            if (AvgO3 > 0.374)
            {
                AvgO3 = retrieveAVG("O3", now, -1);
            }
            double AvgCO = retrieveAVG("CO", now, -8);
            double AvgNO2 = retrieveAVG("NO2", now, -1);

            //convert AvgNO2 from ppm to ppb
            AvgNO2 = AvgNO2 * 1000;
            AvgNO2 = Convert.ToInt32(AvgNO2);

            AvgCO = Math.Round(AvgCO, 1);

            System.Diagnostics.Debug.Write(AvgCO + "\t" + AvgNO2 + "\t" + AvgO3 + "\n");

            //compute AQI index for OZONE
            indexCorrespondent oIc = Ob.search(AvgO3);
            /*
             * when this happens this means that the O3 sensor measured a value higher 
             * than the one defined in the standard, very likely the sensor is broken
             */
            if (oIc == null) 
                O3Index = /*500*/0;
            else
            {
                tmp = ((oIc.maxAqi - oIc.minAqi) / (oIc.maxValue - oIc.minValue) *
                    (AvgO3 - oIc.minValue)) + oIc.minAqi;
                O3Index = Convert.ToInt32(tmp);
            }

            //compute AQI index for CARBON MONOXIDE
            oIc = Cob.search(AvgCO);
            if (oIc == null)
                COIndex = 500;
            else
            {
                tmp = ((oIc.maxAqi - oIc.minAqi) / (oIc.maxValue - oIc.minValue) *
                    (AvgCO - oIc.minValue)) + oIc.minAqi;
                COIndex = Convert.ToInt32(tmp);
            }

            //compute AQI index for NITROGEN DIOXIDE
            oIc = Nob.search(AvgNO2);
            if (oIc == null)
                NO2Index = 500;
            else
            {
                tmp = ((oIc.maxAqi - oIc.minAqi) / (oIc.maxValue - oIc.minValue) *
                    (AvgNO2 - oIc.minValue)) + oIc.minAqi;
                NO2Index = Convert.ToInt32(tmp);
            }
            //select the maximum aqi index
            int AqiIndex = Math.Max(NO2Index, COIndex);
            AqiIndex = Math.Max(AqiIndex, O3Index);

            return AqiIndex;
        }

        /*external AQI*/
        public int computeExternalAqi()
        {
            double tmp;

            DateTime now = DateTime.Now;

            //AQI indexes
            int O3Index = 0;
            int COIndex = 0;
            int NO2Index = 0;

            //compute the various averages
            double AvgO3 = retrieveAVG("EO3", now, -8);
            AvgO3 = Math.Round(AvgO3, 3);
            Ob = new O3Breakpoint(AvgO3);
            if (AvgO3 > 0.374)
            {
                AvgO3 = retrieveAVG("EO3", now, -1);
            }
            double AvgCO = retrieveAVG("ECO", now, -8);
            double AvgNO2 = retrieveAVG("ENO2", now, -1);

            //convert AvgNO2 from ppm to ppb
            AvgNO2 = AvgNO2 * 1000;
            AvgNO2 = Convert.ToInt32(AvgNO2);

            AvgCO = Math.Round(AvgCO, 1);

            System.Diagnostics.Debug.Write(AvgCO + "\t" + AvgNO2 + "\t" + AvgO3 + "\n");

            //compute AQI index for OZONE
            indexCorrespondent oIc = Ob.search(AvgO3);
            /*
             * when this happens this means that the O3 sensor measured a value higher 
             * than the one defined in the standard, very likely the sensor is broken
             */
            if (oIc == null) 
                O3Index = /*500*/0;
            else
            {
                tmp = ((oIc.maxAqi - oIc.minAqi) / (oIc.maxValue - oIc.minValue) *
                    (AvgO3 - oIc.minValue)) + oIc.minAqi;
                O3Index = Convert.ToInt32(tmp);
            }

            //compute AQI index for CARBON MONOXIDE
            oIc = Cob.search(AvgCO);
            if (oIc == null)
                COIndex = 500;
            else
            {
                tmp = ((oIc.maxAqi - oIc.minAqi) / (oIc.maxValue - oIc.minValue) *
                    (AvgCO - oIc.minValue)) + oIc.minAqi;
                COIndex = Convert.ToInt32(tmp);
            }

            //compute AQI index for NITROGEN DIOXIDE
            oIc = Nob.search(AvgNO2);
            if (oIc == null)
                NO2Index = 500;
            else
            {
                tmp = ((oIc.maxAqi - oIc.minAqi) / (oIc.maxValue - oIc.minValue) *
                    (AvgNO2 - oIc.minValue)) + oIc.minAqi;
                NO2Index = Convert.ToInt32(tmp);
            }
            //select the maximum aqi index
            int AqiIndex = Math.Max(NO2Index, COIndex);
            AqiIndex = Math.Max(AqiIndex, O3Index);

            return AqiIndex;
        }
    };



    //class to store value and the correspondent Aqi index
    public class indexCorrespondent 
    {
        public double minValue;
        public double maxValue;
        public int minAqi;
        public int maxAqi;

        public indexCorrespondent(double min, double max, int minA, int maxA)
        {
            minValue = min;
            maxValue = max;
            minAqi = minA;
            maxAqi = maxA;
        }

        public bool compare(double t) 
        {
            if (minValue <= t && t < maxValue)
                return true;
            else
                return false;
        }
    }

    public class O3Breakpoint
    {
        public List<indexCorrespondent> breakpoint = new List<indexCorrespondent>();
            
        /*
         * the variable avg is useful to state if we have to refer to
         * the 1 hour breakpoint or not
         */
        public O3Breakpoint(double Avg) 
        { 
            //in this case we have to refer to the 1-hour breakpoints
            if(Avg > 0.374)
            {
                breakpoint.Add(new indexCorrespondent(0.125, 0.165, 101, 150));
                breakpoint.Add(new indexCorrespondent(0.165, 0.205, 151, 200));
                breakpoint.Add(new indexCorrespondent(0.205, 0.405, 201, 300));
                breakpoint.Add(new indexCorrespondent(0.405, 0.505, 301, 400));
                breakpoint.Add(new indexCorrespondent(0.505, 0.604, 401, 500));
            }
            else
            {
                breakpoint.Add(new indexCorrespondent(0, 0.060, 0, 50));
                breakpoint.Add(new indexCorrespondent(0.060, 0.076, 51, 100));
                breakpoint.Add(new indexCorrespondent(0.076, 0.096, 101, 150));
                breakpoint.Add(new indexCorrespondent(0.096, 0.116, 151, 200));
                breakpoint.Add(new indexCorrespondent(0.116, 0.374, 201, 300));
            }
        }

        //search the correspondent in the list
        public indexCorrespondent search(double t) 
        {
            foreach(indexCorrespondent ic in breakpoint) 
            {
                if(ic.compare(t))
                    return ic;
            }
            return null;
        } 
    }

    public class COBreakpoint
    {
        public List<indexCorrespondent> breakpoint = new List<indexCorrespondent>();

        public COBreakpoint()
        {
            breakpoint.Add(new indexCorrespondent(0, 4.5, 0, 50));
            breakpoint.Add(new indexCorrespondent(4.5, 9.5, 51, 100));
            breakpoint.Add(new indexCorrespondent(9.5, 12.5, 101, 150));
            breakpoint.Add(new indexCorrespondent(12.5, 15.5, 151, 200));
            breakpoint.Add(new indexCorrespondent(15.5, 30.5, 201, 300));
            breakpoint.Add(new indexCorrespondent(30.5, 40.5, 301, 400));
            breakpoint.Add(new indexCorrespondent(40.5, 50.4, 401, 500));
        }

        //search the correspondent in the list
        public indexCorrespondent search(double t)
        {
            foreach (indexCorrespondent ic in breakpoint)
            {
                if (ic.compare(t))
                    return ic;
            }
            return null;
        }
    }

    public class NO2Breakpoint
    {
        public List<indexCorrespondent> breakpoint = new List<indexCorrespondent>();

        public NO2Breakpoint()
        {
            breakpoint.Add(new indexCorrespondent(0, 54, 0, 50));
            breakpoint.Add(new indexCorrespondent(54, 101, 51, 100));
            breakpoint.Add(new indexCorrespondent(101, 361, 101, 150));
            breakpoint.Add(new indexCorrespondent(361, 650, 151, 200));
            breakpoint.Add(new indexCorrespondent(650, 1250, 201, 300));
            breakpoint.Add(new indexCorrespondent(1250, 1650, 301, 400));
            breakpoint.Add(new indexCorrespondent(1650, 2049, 401, 500));
        }

        //search the correspondent in the list
        public indexCorrespondent search(double t)
        {
            foreach (indexCorrespondent ic in breakpoint)
            {
                if (ic.compare(t))
                    return ic;
            }
            return null;
        }

    }
}
