using Gtk;
using NM;


namespace SwaySettings {
    /*
        This class is part of the "ConnectionEditor" class
        This class should be able to edit the general settings of all network devices
    */

    public class IPv4Editor : TemplateEditor{

        protected NM.SettingIP4Config ipv4;

        private Gtk.Entry entry;

        public IPv4Editor (NM.SettingIP4Config ipv4) {
            base( "IPv4");
            this.ipv4 = ipv4;
        }

        public void on_button_save() {
            print("Overwritten Button\n");
        }
    }
}
