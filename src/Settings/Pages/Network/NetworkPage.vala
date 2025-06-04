using Gtk;
using NM;

/*
    https://valadoc.org/libnm/index.htm
*/

namespace SwaySettings {
    /*
        This class is the main class of the network connection page
    */


    public class NetworkPage : Page {

        protected NM.Client client;

        private Gtk.Box window;

        public NetworkPage (SettingsItem item,
                          Adw.NavigationPage page) {
            base (item, page);

            init_nm_client();

            if (client.get_nm_running() == false) {
                display_disabled();
            } else {
                display_lists();
            }
        }

        private void init_nm_client() {
            if (client == null) {
                client = new NM.Client();
            }
        }

        private void display_disabled() {
            var err_label = new Gtk.Label("Network Manager is not running");

            err_label.add_css_class("suggested-action");

            this.set_child(err_label);
        }

        private void display_lists() {
            this.window = new Gtk.Box(Orientation.VERTICAL, 0);

            this.window.set_halign(Gtk.Align.CENTER);

            foreach (var device in this.client.get_devices()) {

                print(device.get_iface() + "\n");

                // Todo: Add option do activate and deactivate device
                var type = device.get_device_type();
                if (!(type == DeviceType.WIFI ||
                    type == DeviceType.ETHERNET ||
                    type == DeviceType.BRIDGE)) {
                        continue;
                    }

                print(device.get_iface() + "\n");

                var content_box = new Gtk.Box(Orientation.VERTICAL, 0);
                content_box.add_css_class("nm-device-box");

                var device_title = "%s - %d".printf(device.get_iface(), device.get_state());

                content_box.append(new Gtk.Label(device_title));
                content_box.append(get_connection_list(device));

                this.window.append(content_box);
            }

            Adw.Clamp clamp = get_clamped_widget (this.window, false);

            this.set_child(clamp);
        }

        private Gtk.ListBox get_connection_list(NM.Device device) {

            var conn_list = new Gtk.ListBox();
            // conn_list.add_css_class("suggested-action");
            conn_list.add_css_class("content");

            // Fetches saved connections
            foreach(var conn in device.get_available_connections()) {

                // Fetches and displays connection name
                string output = "%s".printf(conn.get_setting_connection().get_id());

                var entry = new Gtk.Box(Orientation.HORIZONTAL, 0);
                var label = new Gtk.Label(output);
                entry.add_css_class("nm-list-item");

                entry.append(label);
                // entry.set_child(label);
                var click = new Gtk.GestureClick();
                click.set_button(1); // 1 = left mouse button

                click.pressed.connect((a) => {
                    this.set_child(new ConnectionEditor(device.get_device_type(), conn).get_window());
                });

                entry.add_controller(click);

                conn_list.append( entry );

            }
            return conn_list;
        }
    }
}
