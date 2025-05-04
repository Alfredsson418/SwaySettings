using Gtk;
using NM;

/*
    https://valadoc.org/libnm/index.htm
*/

namespace SwaySettings {
    public class NetworkPage : Page {

        private Client client;

        public NetworkPage (SettingsItem item,
                          Adw.NavigationPage page) {
            base (item, page);
            list_available_conn();
        }

        private void init_nm_client() {
            if (client == null) {
                client = new Client();
            }
        }

        private string get_hostname() {
            init_nm_client();
            return client.hostname;
        }

        private void list_saved_conn() {
            init_nm_client();

            var conn_list = new Gtk.ListBox();

            foreach(var conn in client.get_connections()) {
                var settings = conn.get_setting_connection();
                if (settings == null) { continue; }
                    var id = settings.id;
                    var type = settings.get_connection_type();

                    string output = "%s - %s".printf(id, type);

                    var entry = new Gtk.Label( output );
                    entry.set_margin_top(5);
                    entry.set_margin_bottom(5);
                    entry.set_wrap(true);
                    entry.set_xalign(0); // Align left
                    conn_list.append( entry );

            }

            conn_list.row_selected.connect((row) => {
                if (row != null) {

                }
            });

            this.set_child(conn_list);
        }

        private void list_available_conn() {
            init_nm_client();

            var box = new Box(Orientation.HORIZONTAL, 12);

            var devices = client.get_devices();
            foreach (var device in devices) {

                if (device.get_device_type() == NM.DeviceType.WIFI || device.get_device_type() == NM.DeviceType.ETHERNET) {
                    print("Active device: %s\n", device.get_iface());
                    box.append(new InterfaceList(device).list);
                }
            }
            this.set_child(box);
        }
    }
}
