using Gtk;
using NM;


namespace SwaySettings {
    /*
        This class is part of the "ConnectionEditor" class
        This class should be able to edit the general settings of all network devices
    */

    public class GeneralEditor : TemplateEditor{

        private Gtk.Entry entry;

        public GeneralEditor (NM.Client client) {
            base(client, "General");
            this.save_btn.clicked.connect(this.on_button_save);
        }

        public void on_button_save() {
            print("Overwritten Button\n");
        }
    }
}
