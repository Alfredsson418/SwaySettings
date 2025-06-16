using Gtk;
using NM;


namespace SwaySettings {
    /*
        This class is part of the "ConnectionEditor" class
        This class should be able to edit the general settings of all network devices
    */

    public class IPv6Editor : TemplateEditor{

        protected NM.SettingIP6Config ipv6;

        private Gtk.Entry entry;

        public IPv6Editor (NM.SettingIP6Config ipv6) {
            base("IPv6");
            this.ipv6 = ipv6;
        }

        public void on_button_save() {
            print("Overwritten Button\n");
        }
    }
}
