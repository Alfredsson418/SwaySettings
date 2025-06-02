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
        private NM.Client client;
        protected Gtk.Button save_btn;

        protected TemplateEditor (NM.Client client, string title) {
            this.client = client;
            this.title = title;
            this.save_btn = new Button.with_label("Save");
            this.save_btn.set_size_request(50, 20);
            this.save_btn.set_hexpand(false);
            this.save_btn.set_vexpand(false);


            this.window = new Gtk.Box(Orientation.VERTICAL, 0);
            this.window.append(this.save_btn);
            this.title = "Set title";
        }

        public Gtk.Box get_window() {
            return this.window;
        }

        public string get_title() {
            return this.title;
        }
    }
}
