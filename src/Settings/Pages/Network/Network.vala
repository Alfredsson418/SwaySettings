using Gtk;


namespace SwaySettings {
    public class Network : Page {

        private Gtk.Grid window;

        private Gtk.Box activation_button;
        private Gtk.Box editor_button;
        private Gtk.Box placeholder_button_1;
        private Gtk.Box placeholder_button_2;

        public Network(SettingsItem item, Adw.NavigationPage page) {
            base(item,page);
            window = new Gtk.Grid ();
            window.set_halign (Gtk.Align.CENTER);
            window.set_valign (Gtk.Align.CENTER);

            // Activation page button
            activation_button = new Gtk.Box(Orientation.VERTICAL, 0);
            activation_button.add_css_class ("suggested-action");
            activation_button.add_css_class ("nm-grid-item");
            activation_button.add_css_class ("nm-grid-top-left");
            var activation_label = new Gtk.Label ("Activate a connection");
            activation_button.append (activation_label);
            var activation_gesture = new Gtk.GestureClick ();
            activation_gesture.set_button(1);
            activation_gesture.pressed.connect((a) => {
                this.set_child (new ActivationPage(item, page));
            });
            activation_button.add_controller (activation_gesture);


            // Editor page button
            editor_button = new Gtk.Box(Orientation.VERTICAL, 0);
            editor_button.add_css_class ("suggested-action");
            editor_button.add_css_class ("nm-grid-item");
            editor_button.add_css_class ("nm-grid-top-right");
            var editor_label = new Gtk.Label ("Edit a connection");
            editor_button.append (editor_label);

            // Firewall button?
            placeholder_button_1 = new Gtk.Box(Orientation.VERTICAL, 0);
            placeholder_button_1.add_css_class ("suggested-action");
            placeholder_button_1.add_css_class ("nm-grid-item");
            placeholder_button_1.add_css_class ("nm-grid-bottom-left");
            var placeholder_label_1 = new Gtk.Label ("Placeholder 1");
            placeholder_button_1.append (placeholder_label_1);

            //
            placeholder_button_2 = new Gtk.Box(Orientation.VERTICAL, 0);
            placeholder_button_2.add_css_class ("suggested-action");
            placeholder_button_2.add_css_class ("nm-grid-item");
            placeholder_button_2.add_css_class ("nm-grid-bottom-right");
            var placeholder_label_2 = new Gtk.Label ("Placeholder 2");
            placeholder_button_2.append (placeholder_label_2);

            window.attach (activation_button, 0, 0);
            window.attach (editor_button, 1, 0);
            window.attach (placeholder_button_1, 0, 1);
            window.attach (placeholder_button_2, 1, 1);

            this.set_child (window);

        }
    }
}
