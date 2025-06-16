using Gtk;
using NM;


namespace SwaySettings {
    /*
        This class is part of the "ConnectionEditor" class
        This class should be able to edit the general settings of all network devices
    */

    public class WIFIEditor : TemplateEditor{

        protected NM.SettingWireless wifi;

        private Gtk.Entry entry;

        public WIFIEditor (NM.SettingWireless wifi) {
            base("WIFI");
            this.wifi = wifi;
        }

        public void on_button_save() {
            print("Overwritten Button\n");
        }
    }
}
