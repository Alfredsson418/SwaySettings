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
        protected Gtk.Button save_btn;

        protected TemplateEditor (string title) {
            this.title = title;
            this.save_btn = new Button.with_label("Save");
            this.save_btn.set_halign(Gtk.Align.CENTER);
            this.save_btn.add_css_class("suggested-action");


            this.window = new Gtk.Box(Orientation.VERTICAL, 0);
            this.window.append(this.save_btn);
        }

        public Gtk.Box get_window() {
            return this.window;
        }

        public string get_title() {
            return this.title;
        }
    }
}
