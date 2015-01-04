using System;
using System.Collections.Generic;
using System.Linq;
using System.Windows.Forms;

namespace usbSensor
{
    static class Program
    {
        /// <summary>
        /// Punto di ingresso principale dell'applicazione.
        /// </summary>
        [STAThread]
        static void Main()
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            //Form1 f = new Form1();
            //Update u = new Update(f);
            //System.Threading.Thread newThread =
            //   new System.Threading.Thread(u.updateForm);
            Application.Run(new Form1());
            //u.Run();
        }
    }
}
