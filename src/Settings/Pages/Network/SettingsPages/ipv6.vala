using Gtk;
using NM;


namespace SwaySettings {
    /*
        This class is part of the "ConnectionEditor" class
        This class should be able to edit the general settings of all network devices
    */

    public class IPv6Editor : TemplateEditor{

        private Gtk.Entry entry;

        public IPv6Editor (NM.RemoteConnection conn) {
            base("IPv6");
            this.save_btn.clicked.connect(this.on_button_save);
        }

        public void on_button_save() {
            print("Overwritten Button\n");
        }
    }
}
