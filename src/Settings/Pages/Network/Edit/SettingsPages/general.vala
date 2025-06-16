using Gtk;
using NM;


namespace SwaySettings {
    /*
        This class is part of the "ConnectionEditor" class
        This class should be able to edit the general settings of all network devices
    */

    public class GeneralEditor : TemplateEditor{

        protected NM.SettingConnection general;

        private Gtk.Entry entry;

        public GeneralEditor (NM.SettingConnection general) {
            base("General");
            this.general = general;
        }

        public void on_button_save() {
            print("Overwritten Button\n");
        }
    }
}
