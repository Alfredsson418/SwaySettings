using NM;

namespace SwaySettings {
    /*
        Helper functions for NM.Device
    */


    public class NetworkDevice {

        public NetworkDevice () {
            // this.device = device;
        }


        public static string get_device_state(NM.Device device) {
            switch (device.get_state()) {
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
    }
}
