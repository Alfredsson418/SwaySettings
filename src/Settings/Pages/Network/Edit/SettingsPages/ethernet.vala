using Gtk;
using NM;


namespace SwaySettings {
    /*
        This class is part of the "ConnectionEditor" class
        This class should be able to edit the general settings of all network devices
    */

    public class EthernetEditor : TemplateEditor{

        protected NM.SettingWired eth;

        private Gtk.Entry entry;

        public EthernetEditor (NM.SettingWired eth) {
            base("Ethernet");
            this.eth = eth;
        }

        public void on_button_save() {
            print("Overwritten Button\n");
        }
    }
}
