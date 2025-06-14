using NM;
using Gtk;

namespace SwaySettings {

    /*
        Helper functions for NM.RemoteConnection
    */

    public class NetworkConnection {

        private NM.Client client;
        private NM.Device device;
        private NM.RemoteConnection conn;

        private Gtk.Box widget;
        private Gtk.Label label;

        private bool conn_active;


        public NetworkConnection (NM.Client client, NM.Device device, NM.RemoteConnection conn) {
            this.client = client;
            this.conn = conn;
            this.device = device;
            this.widget = new Box(Orientation.HORIZONTAL, 0);

            this.label = new Gtk.Label("Placeholder");

            this.widget.append(label);
            this.widget.add_css_class("nm-list-item");

            this.conn_active = this.is_active();

            this.update_conn_label();



        }


        private async void update_conn_label() {
            string output;

            if (this.conn_active) {
                output = "* %s".printf(conn.get_setting_connection().get_id());
            } else {
                output = "%s".printf(conn.get_setting_connection().get_id());
            }

            label.set_text(output);
        }

        public Gtk.Box get_widget() {
            return this.widget;

        }

        public bool is_active() {
            foreach(var active in client.get_active_connections()) {
                if (active != null && active.get_uuid() == conn.get_uuid()) {
                    return true;
                }
            }
            return false;
        }

        public NM.ActiveConnection get_active_connection() {
            foreach(var active in client.get_active_connections()) {
                if (active != null && active.get_uuid() == conn.get_uuid()) {
                    return active;
                }
            }
            return null;
        }

        public async void toggle_update_connection() {
            var temp_conn = this.get_active_connection();
            if (temp_conn == null) {
                try {
                    var result = yield client.activate_connection_async(conn, device, null, null);
                    print("Connection activated: %s\n", result.get_id());
                    this.conn_active = true;
                } catch (Error e) {
                    print("Failed to activate: %s\n", e.message);
                }
                // entry.set_child(NetworkConnection.get_conn_label(client, conn));

            } else {
                client.deactivate_connection_async(temp_conn, null);
                print("Deactivation requested.\n");
                this.conn_active = false;
                // entry.set_child(NetworkConnection.get_conn_label(client, conn));
            }
            update_conn_label();
        }

    }
}
