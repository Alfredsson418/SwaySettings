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

                var device_title = "%s - %s".printf(device.get_iface(), get_device_state(device.get_state()));

                content_box.append(new Gtk.Label(device_title));
                content_box.append(get_connection_list(device));

                // content_box.add_css_class(string css_class);

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

                // Edit connection
                var left_click = new Gtk.GestureClick();
                left_click.set_button(1); // 1 = left mouse button, 2 middle mouse, 3 right click
                left_click.pressed.connect((a) => {
                    this.set_child(new ConnectionEditor(device.get_device_type(), conn).get_window());
                });

                // Togggle Connect/Disconnect
                var right_click = new Gtk.GestureClick();
                right_click.set_button(3); // 1 = left mouse button, 2 middle mouse, 3 right click
                right_click.pressed.connect((a) => {

                });

                entry.add_controller(left_click);
                entry.add_controller(right_click);

                conn_list.append( entry );

            }
            return conn_list;
        }

        public static string get_device_state(NM.DeviceState state) {
            switch (state) {
                case ACTIVATED:
                    return "Activated";
                case CONFIG:
                    return "Config";
                case DEACTIVATING:
                    return "Deactivating";
                case DISCONNECTED:
                    return "Disconnected";
                case FAILED:
                    return "Failed";
                case IP_CHECK:
                    return "IP Check";
                case IP_CONFIG:
                    return "IP Config";
                case NEED_AUTH:
                    return "Needs Auth";
                case PREPARE:
                    return "Prepare";
                case SECONDARIES:
                    return "Secondaries";
                case UNAVAILABLE:
                    return "Unavailable";
                case UNMANAGED:
                    return "Unmanaged";
                case UNKNOWN:
                default:
                    return "Unknown";
            }
        }
    }
}
