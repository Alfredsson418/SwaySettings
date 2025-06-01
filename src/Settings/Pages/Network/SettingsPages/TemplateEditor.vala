using Gtk;
using NM;


namespace SwaySettings {
    /*
        This class is part of the "ConnectionEditor" class
        This class should be able to edit the general settings of all network devices
    */

    public class TemplateEditor {

        private Gtk.Box window;

        private string title;

        private NM.Client client;

        public TemplateEditor (NM.Client client) {
            this.client = client;

            title = "Set title";

            window = new Gtk.Box(Orientation.VERTICAL, 0);
        }

        public Gtk.Box get_window() {
            return this.window;
        }

        public string get_title() {
            return this.title;
        }
    }
}
