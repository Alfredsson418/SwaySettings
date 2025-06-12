using NM;
using Gtk;

namespace SwaySettings {

    /*
        Helper functions for NM.RemoteConnection
    */

    public class NetworkConnection {

        public NetworkConnection () {
            // this.device = device;
        }

        public static Gtk.Box get_conn_label(NM.Client client, NM.RemoteConnection conn) {

            string output;

            if (NetworkConnection.is_active(client, conn)) {
                output = "* %s".printf(conn.get_setting_connection().get_id());
            } else {
                output = "%s".printf(conn.get_setting_connection().get_id());
            }

            var label = new Gtk.Label(output);

            var box = new Gtk.Box(Orientation.HORIZONTAL, 0);

            box.append(label);
            box.add_css_class("nm-list-item");

            return box;

        }

        public static bool is_active(NM.Client client, NM.RemoteConnection conn) {
            foreach(var active in client.get_active_connections()) {
                if (active != null && active.get_uuid() == conn.get_uuid()) {
                    return true;
                }
            }
            return false;
        }

        public static NM.ActiveConnection get_active_connection(NM.Client client, NM.RemoteConnection conn) {
            foreach(var active in client.get_active_connections()) {
                if (active != null && active.get_uuid() == conn.get_uuid()) {
                    return active;
                }
            }
            return null;
        }

        public static void toggle_connection(NM.Client client, NM.Device device, NM.RemoteConnection conn) {
            var temp_conn = NetworkConnection.get_active_connection(client, conn);
            if (temp_conn == null) {
                client.activate_connection_async(conn, device, null, null, (a) => {
                    print("Connection activated.\n");
                });
            } else {
                client.deactivate_connection_async(temp_conn, null, (a) => {
                    print("Connection deactivated.\n");
                });
            }
        }

    }
}
