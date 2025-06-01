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

        private NM.Client client;

        public ConnectionEditor(NM.Client client) {
            this.client = client;


            stack = new Adw.ViewStack ();
            header = new Adw.HeaderBar ();
            switcher = new Adw.ViewSwitcher ();

            // This removes the minimize,maximize,close buttons
            header.set_decoration_layout ("");


            stack.add_titled(new GeneralEditor(this.client).get_window(), "General", new GeneralEditor(this.client).get_title());


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
