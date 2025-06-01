using Gtk;
using NM;

namespace SwaySettings {

    /*
        This class should be able to fetch all network connection based on different criterials,
        NOT DISPLAY THEM
    */

    public class InterfaceList {

        public Gtk.ListBox list;

        private Gtk.Notebook notebook;

        private Device interface;

        private Page parent;

        public InterfaceList(Device interface, Page Parent) {
            // Optional: Set selection mode or do setup
            // this.list.set_selection_mode(Gtk.SelectionMode.SINGLE);

            list = new Gtk.ListBox();
            notebook = new Gtk.Notebook();
            this.parent = Parent;

            this.interface = interface;

            if (this.interface.get_device_type() == NM.DeviceType.WIFI) {
                this.wifi_list();
            } else if (this.interface.get_device_type() == NM.DeviceType.ETHERNET) {
                default_list();
            } else {
                default_list();
            }

            this.list.row_selected.connect((row) => {
                ;
            });
        }

        private void default_list() {
            var available_c = this.interface.get_available_connections();

            foreach (var c in available_c) {
                var setting = c.get_setting_connection();

                if (setting != null) {
                    print("%s\n", setting.get_id());
                    string output = "%s".printf(setting.get_id());

                    print("Name: %s\n", output);

                    var entry = new Gtk.Label( output );
                    entry.set_margin_top(5);
                    entry.set_margin_bottom(5);
                    this.list.append( entry );
                }
            }
        }

        private void wifi_list() {
            NM.DeviceWifi interface = this.interface as NM.DeviceWifi;

            foreach (var ap in interface.get_access_points()) {

                var ssid_bytes = ap.get_ssid(); // returns GLib.Bytes
                if (ssid_bytes != null) {
                    // Convert bytes to string
                    var ssid = (string) ssid_bytes.get_data();

                    string output = "%s - %d%".printf(ssid, ap.strength);

                    print("SSID: %s\n", output);

                    var entry = new Gtk.Label( output );
                    entry.set_margin_top(5);
                    entry.set_margin_bottom(5);
                    this.list.append( entry );
                }
            }
        }
    }
}
