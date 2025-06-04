using Gtk;
using NM;


namespace SwaySettings {
    /*
        This class is part of the "ConnectionEditor" class
        This class should be able to edit the general settings of all network devices
    */

    public class EthernetEditor : TemplateEditor{

        private Gtk.Entry entry;

        public EthernetEditor (NM.RemoteConnection conn) {
            base("Ethernet");
            this.save_btn.clicked.connect(this.on_button_save);
        }

        public void on_button_save() {
            print("Overwritten Button\n");
        }
    }
}
