using NM;
using Gtk;

namespace SwaySettings {

    /*
        This class is the menu for a specific connection
        This class should handle both ethernet, wifi and a fallback device
        Menus should include:
            - General Settings
            - Ethernet/Wifi Settings
            - IPv4 Settings
            - IPv6 Settings
    */

    public class ConnectionEditor {

        private Adw.ViewSwitcher switcher;
        private Adw.HeaderBar header;
        private Adw.ViewStack stack;

        private Gtk.Box window;

        public ConnectionEditor(NM.DeviceType type, NM.RemoteConnection conn) {

            stack = new Adw.ViewStack ();
            header = new Adw.HeaderBar ();
            switcher = new Adw.ViewSwitcher ();

            // This removes the minimize,maximize,close buttons
            header.set_decoration_layout ("");

            var general_editor = new GeneralEditor(conn);
            stack.add_titled(general_editor.get_window(), "General", general_editor.get_title());

            if (type == NM.DeviceType.ETHERNET) {
                var eth_editor = new EthernetEditor (conn);
                stack.add_titled(eth_editor.get_window(), "Ethernet", eth_editor.get_title ());
            } else if (type == NM.DeviceType.WIFI) {
                var wifi_editor = new WIFIEditor(conn);
                stack.add_titled(wifi_editor.get_window (), "Wifi", wifi_editor.get_title ());
            }

            var ipv4 = conn.get_setting_ip4_config();
            if (ipv4 != null && ipv4.method != "disabled") {
                var ipv4_editor = new IPv4Editor(conn);
                stack.add_titled(ipv4_editor.get_window(), "ipv4", ipv4_editor.get_title());
            }

            var ipv6 = conn.get_setting_ip6_config();
            if (ipv6 != null && ipv6.method != "disabled") {
                var ipv6_editor = new IPv6Editor(conn);
                stack.add_titled(ipv6_editor.get_window(), "ipv6", ipv6_editor.get_title());
            }

            header.set_halign(Gtk.Align.CENTER);
            header.add_css_class("suggested-action");
            header.add_css_class("nm-header");

            switcher.set_stack(stack);

            header.set_title_widget(switcher);

            window = new Gtk.Box(Orientation.VERTICAL, 0);

            window.append(header);
            window.append(stack);
        }

        public Gtk.Box get_window() {
            return this.window;
        }
     }
}
