using Gtk;
using NM;

namespace SwaySettings {
    /*
        This class is part of the "ConnectionEditor" class
        This class should be able to edit the general settings of all network devices
    */

    public abstract class TemplateEditor {

        protected Gtk.Box window;
        protected string title;

        protected TemplateEditor (string title) {
            this.title = title;
            this.window = new Gtk.Box(Orientation.VERTICAL, 0);
        }

        public Gtk.Box get_window() {
            return this.window;
        }

        public string get_title() {
            return this.title;
        }
    }
}
