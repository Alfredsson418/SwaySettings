using Gtk;

namespace SwaySettings {
    public class DisplayList {
        private Gtk.Box widget;

        public DisplayList(string title, Gtk.ListBox body) {
            this.widget = new Gtk.Box(Orientation.VERTICAL, 0);
            this.widget.set_halign(Gtk.Align.CENTER);
            this.widget.add_css_class("nm-device-box");

            var label = new Gtk.Label(title);
            label.add_css_class("suggested-action");

            body.add_css_class("content");

            this.widget.append(label);
            this.widget.append(body);
            this.widget.set_visible(false);
        }

        public Gtk.Box get_widget() {
            return widget;
        }
    }
}
