using NM;
using Gtk;

namespace SwaySettings {
    /*
        Helper functions for NM.Device
    */


    public class NetworkDevice {

        private NM.Device device;

        private Gtk.Box widget;
        private Gtk.Label label;

        public NetworkDevice (NM.Device device) {
            this.device = device;
            this.label = new Gtk.Label("Placeholder");

            this.widget = new Gtk.Box(Orientation.HORIZONTAL, 0);
            this.widget.set_halign(Gtk.Align.CENTER);
            this.widget.append(label);

            update_device_label();
        }


        public void update_device_label() {
            this.label.set_text("%s - %s".printf(device.get_iface(), this.get_device_state()));
        }

        public Gtk.Box get_widget() {
            return this.widget;
        }

        public string get_device_state() {
            switch (this.device.get_state()) {
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

        public static bool is_approved(NM.DeviceType type) {
            foreach(var d in get_approved()) {
                if (d == type) {
                    return true;
                }
            }
            return false;
        }

        public static NM.DeviceType[] get_approved() {
            return {
                WIFI,
                ETHERNET,
                BRIDGE
            };
        }
    }
}
