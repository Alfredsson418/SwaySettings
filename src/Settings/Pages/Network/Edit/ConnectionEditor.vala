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

    public class ConnectionEditor : Page {

        private Adw.ViewSwitcher switcher;
        private Adw.HeaderBar header;
        private Adw.ViewStack stack;

        protected Gtk.Button save_btn;
        private Gtk.Box window;

        private GeneralEditor general_page;
        private EthernetEditor eth_page;
        private WIFIEditor wifi_page;
        private IPv4Editor ipv4_page;
        private IPv6Editor ipv6_page;

        public ConnectionEditor(SettingsItem item,
                          Adw.NavigationPage page,
                          NM.DeviceType type, NM.RemoteConnection conn) {

            base(item, page);

            this.stack = new Adw.ViewStack ();
            this.header = new Adw.HeaderBar ();
            this.switcher = new Adw.ViewSwitcher ();

            this.save_btn = new Button.with_label("Save");
            this.save_btn.set_halign(Gtk.Align.CENTER);
            this.save_btn.add_css_class("suggested-action");
            this.save_btn.clicked.connect(this.on_button_save);

            // This removes the minimize,maximize,close buttons
            this.header.set_decoration_layout("");

            this.general_page = new GeneralEditor(conn.get_setting_connection());
            this.stack.add_titled(this.general_page.get_window(), "General", this.general_page.get_title());

            if (type == NM.DeviceType.ETHERNET) {
                this.eth_page = new EthernetEditor(conn.get_setting_wired());
                this.stack.add_titled(this.eth_page.get_window(), "Ethernet", this.eth_page.get_title ());
            } else if (type == NM.DeviceType.WIFI) {
                this.wifi_page = new WIFIEditor(conn.get_setting_wireless());
                this.stack.add_titled(this.wifi_page.get_window (), "Wifi", this.wifi_page.get_title ());
            }

            var ipv4 = conn.get_setting_ip4_config();
            if (ipv4 != null && ipv4.method != "disabled") {
                this.ipv4_page = new IPv4Editor(ipv4);
                this.stack.add_titled(this.ipv4_page.get_window(), "ipv4", this.ipv4_page.get_title());
            }

            var ipv6 = conn.get_setting_ip6_config();
            if (ipv6 != null && ipv6.method != "disabled") {
                this.ipv6_page = new IPv6Editor(ipv6);
                this.stack.add_titled(this.ipv6_page.get_window(), "ipv6", this.ipv6_page.get_title());
            }

            this.header.set_halign(Gtk.Align.CENTER);
            this.header.add_css_class("suggested-action");
            this.header.add_css_class("nm-header");

            this.switcher.set_stack(this.stack);

            this.header.set_title_widget(this.switcher);

            this.window = new Gtk.Box(Orientation.VERTICAL, 0);

            this.window.append(this.header);
            this.window.append(this.stack);
            this.window.append(this.save_btn);
        }

        public Gtk.Box get_window() {
            return this.window;
        }

        private void on_button_save() {
            print("test\n");
        }
     }
}
