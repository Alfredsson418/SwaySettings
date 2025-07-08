using Gtk;
using NM;

/*
    https://valadoc.org/libnm/index.htm
*/

namespace SwaySettings {
    /*
        This class is the main class of the network connection page
    */
    public class EditorPage : PageScroll {

        protected NM.Client client;

        private Gtk.Box window;

        public override Gtk.Widget set_child () {
            return this.window;
        }

        public EditorPage (SettingsItem item,
                          Adw.NavigationPage page, NM.Client client) {
            base (item, page);

            this.client = client;

            this.window = new Gtk.Box(Orientation.VERTICAL, 0);

            this.window.set_halign(Gtk.Align.CENTER);

            display_lists();
        }

        private async void display_lists() {


            foreach(var d in NetworkDevice.get_approved()) {

            }

            var ethernet = new Gtk.ListBox();
            var ethernet_box = new DisplayList("Ethernet", ethernet).get_widget();
            this.window.append(ethernet_box);

            var wifi = new Gtk.ListBox();
            var wifi_box = new DisplayList("Wifi", wifi).get_widget();
            this.window.append(wifi_box);

            var vpn = new Gtk.ListBox();
            var vpn_box = new DisplayList("Vpn", vpn).get_widget();
            this.window.append(vpn_box);

            var bridge = new Gtk.ListBox();
            var bridge_box = new DisplayList("Bridge", bridge).get_widget();
            this.window.append(bridge_box);

            var other = new Gtk.ListBox();
            var other_box = new DisplayList("Other", other).get_widget();
            this.window.append(other_box);

            foreach (var conn in client.get_connections()) {
                var s = conn.get_setting_connection();
                if (s == null) continue;
                print("%s %s\n", s.get_connection_type(), s.get_id());
                var temp = new NetworkConnection(client, conn, false);
                switch (s.get_connection_type()) {
                    case "802-11-wireless":
                        wifi.append(temp.get_widget());
                        wifi_box.set_visible(true);
                        break;
                    case "802-3-ethernet":
                        ethernet.append(temp.get_widget());
                        ethernet_box.set_visible(true);
                        break;
                    case "vpn":
                    case "wireguard":
                        vpn.append(temp.get_widget());
                        vpn_box.set_visible(true);
                        break;
                    case "bridge":
                        bridge.append(temp.get_widget());
                        bridge_box.set_visible(true);
                        break;
                    default:
                        other.append(temp.get_widget());
                        other_box.set_visible(true);
                        break;
                }
            }
        }
    }
}
