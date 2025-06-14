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
                this.window = new Gtk.Box(Orientation.VERTICAL, 0);

                this.window.set_halign(Gtk.Align.CENTER);

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

        private async void display_lists() {

            foreach (var device in this.client.get_devices()) {


                // Todo: Add option do activate and deactivate device
                var type = device.get_device_type();
                if (!(type == DeviceType.WIFI ||
                    type == DeviceType.ETHERNET ||
                    type == DeviceType.BRIDGE)) {
                    continue;
                }

                var device_class = new NetworkDevice(device);


                device.state_changed.connect((a) => {
                    device_class.update_device_label();
                });

                var content_box = new Gtk.Box(Orientation.VERTICAL, 0);
                content_box.add_css_class("nm-device-box");


                content_box.append(device_class.get_widget());
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

                var conn_class = new NetworkConnection(client, device, conn);

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
                    conn_class.toggle_update_connection();
                });

                var entry = conn_class.get_widget();

                entry.add_controller(left_click);
                entry.add_controller(right_click);

                conn_list.append( entry );
            }
            return conn_list;
        }
    }
}
