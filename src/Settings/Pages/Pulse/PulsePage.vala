using PulseAudio;
using Gee;

namespace SwaySettings {
    public class PulsePage : PageScroll {
        PulseContent content;

        public PulsePage (SettingsItem item, Adw.NavigationPage page) {
            base (item, page);
        }

        public override Gtk.Widget set_child () {
            this.content = new PulseContent ();
            return this.content;
        }

        public override async void on_back (Adw.NavigationPage page) {
            yield this.content.on_back ();
        }
    }

    [GtkTemplate (ui = "/org/erikreider/swaysettings/ui/PulseContent.ui")]
    private class PulseContent : Adw.Bin {
        private enum DeviceColumns {
            COLUMN_KEY,
            COLUMN_DEVICE,
            COLUMN_ICON,
            COLUMN_NAME,
            N_COLUMNS
        }

        private enum ProfileColumns {
            COLUMN_KEY,
            COLUMN_DEVICE,
            COLUMN_PROFILE,
            COLUMN_NAME,
            N_COLUMNS
        }

        public const string TOGGLE_ICON_MUTED = "audio-volume-muted-symbolic";
        public const string TOGGLE_ICON_UNMUTED = "audio-volume-high-symbolic";

        [GtkChild]
        unowned Gtk.Stack stack;

        [GtkChild]
        unowned Gtk.Box pulse_page;
        [GtkChild]
        unowned Gtk.Box error_page;

        // Sink
        [GtkChild]
        unowned Adw.PreferencesGroup output_group;
        [GtkChild]
        unowned Gtk.Label output_value;
        [GtkChild]
        unowned Gtk.Scale output_slider;
        [GtkChild]
        unowned Gtk.ToggleButton output_mute_toggle;
        [GtkChild]
        unowned Gtk.ComboBox output_combo_box;
        Gtk.ListStore sink_list_store;

        // Bluetooth Profile ComboBox
        [GtkChild]
        unowned Adw.ActionRow output_profile_row;
        [GtkChild]
        unowned Gtk.ComboBox profile_combo_box;
        Gtk.ListStore profile_list_store;

        // Source
        [GtkChild]
        unowned Adw.PreferencesGroup input_group;
        [GtkChild]
        unowned Gtk.Label input_value;
        [GtkChild]
        unowned Gtk.Scale input_slider;
        [GtkChild]
        unowned Gtk.ToggleButton input_mute_toggle;
        [GtkChild]
        unowned Gtk.ComboBox input_combo_box;
        Gtk.ListStore source_list_store;

        // Sink inputs
        [GtkChild]
        public unowned Gtk.ListBox levels_listbox;
        [GtkChild]
        public unowned Adw.PreferencesGroup sink_inputs_group;

        private PulseDevice ? default_sink = null;
        private PulseDevice ? default_source = null;

        private PulseDaemon client = new PulseDaemon ();

        construct {
            this.client.change_device.connect (device_change);
            this.client.new_device.connect (device_added);
            this.client.remove_device.connect (device_removed);

            this.client.change_active_sink.connect (active_sink_change);
            this.client.new_active_sink.connect (active_sink_added);
            this.client.remove_active_sink.connect (active_sink_removed);

            this.client.change_default_device.connect (default_device_changed);

            this.client.bind_property ("running", stack, "visible-child",
                                       BindingFlags.SYNC_CREATE,
                                       (bind, from_value, ref to_value) => {
                to_value = error_page;
                if (!from_value.holds (Type.BOOLEAN)) return false;
                if (!from_value.get_boolean ()) return true;
                to_value = pulse_page;
                return true;
            });

            stack.set_visible_child (client.running ? pulse_page : error_page);
            this.client.notify["running"].connect (() => {
                stack.set_visible_child ((client.running ? pulse_page : error_page));
            });

            // UI signals
            output_mute_toggle.bind_property ("active",
                                              output_slider, "sensitive",
                                              BindingFlags.INVERT_BOOLEAN);
            output_mute_toggle.toggled.connect ((b) => {
                this.client.set_device_mute (b.active, default_sink);
            });
            input_mute_toggle.bind_property ("active",
                                             input_slider, "sensitive",
                                             BindingFlags.INVERT_BOOLEAN);
            input_mute_toggle.toggled.connect ((b) => {
                this.client.set_device_mute (b.active, default_source);
            });

            output_combo_box.changed.connect (combo_box_changed);
            profile_combo_box.changed.connect (profile_combo_box_changed);
            input_combo_box.changed.connect (combo_box_changed);

            output_slider.value_changed.connect (() => {
                output_value.label = "%.0lf".printf(Math.round (output_slider.get_value ()));
                this.client.set_device_volume (
                    default_sink,
                    (float) output_slider.get_value ());
            });
            input_slider.value_changed.connect (() => {
                input_value.label = "%.0lf".printf(Math.round (input_slider.get_value ()));
                this.client.set_device_volume (
                    default_source,
                    (float) input_slider.get_value ());
            });

            output_group.set_sensitive (false);
            input_group.set_sensitive (false);
            sink_inputs_group.set_sensitive (false);
        }

        public PulseContent () {
            var cell_render_icon = new Gtk.CellRendererPixbuf ();
            cell_render_icon.set_padding (8, 0);
            var cell_render_text = new Gtk.CellRendererText ();
            cell_render_text.ellipsize = Pango.EllipsizeMode.END;

            // Sinks
            sink_list_store = new Gtk.ListStore (
                DeviceColumns.N_COLUMNS,
                typeof (string), typeof (unowned PulseDevice),
                typeof (string), typeof (string));
            sink_list_store.set_sort_column_id (
                DeviceColumns.COLUMN_KEY, Gtk.SortType.ASCENDING);

            foreach (var item in this.client.sinks.values) {
                device_added (item);
            }
            output_combo_box.set_model (sink_list_store);
            output_combo_box.pack_start (cell_render_icon, false);
            output_combo_box.add_attribute (cell_render_icon,
                                            "icon-name", DeviceColumns.COLUMN_ICON);
            output_combo_box.pack_start (cell_render_text, true);
            output_combo_box.add_attribute (cell_render_text,
                                            "text", DeviceColumns.COLUMN_NAME);

            // Sink Bluetooth Profiles
            profile_list_store = new Gtk.ListStore (
                ProfileColumns.N_COLUMNS,
                typeof (string), // Key
                typeof (PulseDevice), // Device
                typeof (PulseCardProfile), // Profile
                typeof (string)); // Name
            profile_list_store.set_sort_column_id (
                ProfileColumns.COLUMN_KEY, Gtk.SortType.ASCENDING);

            profile_combo_box.set_model (profile_list_store);
            profile_combo_box.pack_start (cell_render_text, true);
            profile_combo_box.add_attribute (cell_render_text,
                                             "text", ProfileColumns.COLUMN_NAME);

            // Sink slider and mute toggle button
            output_slider.add_mark (25, Gtk.PositionType.LEFT, null);
            output_slider.add_mark (50, Gtk.PositionType.TOP, null);
            output_slider.add_mark (75, Gtk.PositionType.TOP, null);

            output_mute_toggle.toggled.connect (mute_toggle_cb);

            // Sources
            source_list_store = new Gtk.ListStore (
                DeviceColumns.N_COLUMNS,
                typeof (string), typeof (unowned PulseDevice),
                typeof (string), typeof (string));
            source_list_store.set_sort_column_id (
                DeviceColumns.COLUMN_KEY, Gtk.SortType.ASCENDING);

            foreach (var item in this.client.sources.values) {
                device_added (item);
            }
            input_combo_box.set_model (source_list_store);
            input_combo_box.pack_start (cell_render_icon, false);
            input_combo_box.add_attribute (cell_render_icon,
                                           "icon-name", DeviceColumns.COLUMN_ICON);
            input_combo_box.pack_start (cell_render_text, true);
            input_combo_box.add_attribute (cell_render_text,
                                           "text", DeviceColumns.COLUMN_NAME);

            input_slider.add_mark (25, Gtk.PositionType.TOP, null);
            input_slider.add_mark (50, Gtk.PositionType.TOP, null);
            input_slider.add_mark (75, Gtk.PositionType.TOP, null);

            input_mute_toggle.toggled.connect (mute_toggle_cb);

            // Active sink inputs
            foreach (var item in this.client.active_sinks.values) {
                levels_listbox.append (new SinkInputRow (item, client));
            }
            if (client.active_sinks.values.size > 0) {
                sink_inputs_group.set_sensitive (true);
            }
            levels_listbox.set_sort_func (this.active_sinks_list_store_sort);

            // Begin
            this.client.start ();
        }

        public async void on_back () {
            this.client.change_device.disconnect (device_change);
            this.client.new_device.disconnect (device_added);
            this.client.remove_device.disconnect (device_removed);

            this.client.change_active_sink.disconnect (active_sink_change);
            this.client.new_active_sink.disconnect (active_sink_added);
            this.client.remove_active_sink.disconnect (active_sink_removed);

            this.client.change_default_device.disconnect (default_device_changed);

            this.client.close ();
        }

        private void mute_toggle_cb (Gtk.ToggleButton button) {
            string icon = button.active ? TOGGLE_ICON_MUTED : TOGGLE_ICON_UNMUTED;
            button.set_icon_name (icon);
        }

        private async void combo_box_changed (Gtk.ComboBox combo) {
            Gtk.ListStore list_store = (Gtk.ListStore) combo.get_model ();
            PulseDevice ? device = get_selected_device (combo, list_store);
            if (device == null) return;
            PulseDevice ? cmp_device = device.direction == PulseAudio.Direction.INPUT ?
                                       default_source : default_sink;

            // Check if setting the same device
            if (cmp_device != null && device.cmp (cmp_device)) return;

            combo.changed.disconnect (combo_box_changed);
            yield this.client.set_default_device (device);

            Gtk.TreeIter iter = find_device_iter (list_store, device);
            combo.set_active_iter (iter);
            combo.changed.connect (combo_box_changed);
        }

        private async void profile_combo_box_changed (Gtk.ComboBox combo) {
            Gtk.ListStore list_store = (Gtk.ListStore) combo.get_model ();
            PulseCardProfile ? profile = get_selected_device_profile (combo, list_store);
            if (profile == null) return;
            PulseDevice ? device = get_selected_device (output_combo_box,
                                                        sink_list_store);

            // Check if setting the same device
            if (device != null &&
                device.active_profile != null &&
                profile.cmp (device.active_profile)) return;

            combo.changed.disconnect (profile_combo_box_changed);
            yield this.client.set_bluetooth_card_profile (profile, device);

            combo.changed.connect (profile_combo_box_changed);
        }

        /*
         * Getters
         */

        private PulseDevice ? get_selected_device (Gtk.ComboBox combo_box,
                                                   Gtk.ListStore list_store) {
            Gtk.TreeIter iter;
            combo_box.get_active_iter (out iter);
            if (!list_store.iter_is_valid (iter)) return null;
            Value val;
            list_store.get_value (iter, DeviceColumns.COLUMN_DEVICE, out val);

            if (!val.holds (Type.OBJECT)) return null;
            unowned Object obj = val.get_object ();
            if (!(obj is PulseDevice)) return null;
            return (PulseDevice) obj;
        }

        private Gtk.TreeIter ? find_device_iter (Gtk.ListStore list_store,
                                                 PulseDevice device) {
            Gtk.TreeIter ? iter = null;
            list_store.foreach ((model, path, it) => {
                Value value;
                model.get_value (it, DeviceColumns.COLUMN_DEVICE, out value);
                PulseDevice d = (PulseDevice) value;
                if (d.cmp (device)) {
                    iter = it;
                    return true;
                }
                return false;
            });
            return iter;
        }

        private PulseCardProfile ? get_selected_device_profile (Gtk.ComboBox combo_box,
                                                                Gtk.ListStore list_store) {
            Gtk.TreeIter iter;
            combo_box.get_active_iter (out iter);
            if (!list_store.iter_is_valid (iter)) return null;
            Value val;
            list_store.get_value (iter, ProfileColumns.COLUMN_PROFILE, out val);

            if (!val.holds (Type.OBJECT)) return null;
            unowned Object obj = val.get_object ();
            if (!(obj is PulseCardProfile)) return null;
            return (PulseCardProfile) obj;
        }

        private void set_device_profiles (PulseDevice device) {
            profile_combo_box.changed.disconnect (profile_combo_box_changed);

            Gtk.TreeIter ? default_profile = null;
            profile_list_store.clear ();
            foreach (var profile in device.profiles.data) {
                Gtk.TreeIter iter;
                profile_list_store.append (out iter);
                profile_list_store.set (
                    iter,
                    ProfileColumns.COLUMN_KEY, profile.name,
                    ProfileColumns.COLUMN_DEVICE, device,
                    ProfileColumns.COLUMN_PROFILE, profile,
                    ProfileColumns.COLUMN_NAME, profile.description,
                    -1);

                // Check if active profile
                if (profile.name == device.card_active_profile) {
                    default_profile = iter;
                }
            }

            profile_combo_box.set_active_iter (default_profile);

            profile_combo_box.changed.connect (profile_combo_box_changed);
        }

        /*
         * Sinks/Sources
         */

        private void device_change (PulseDevice device) {
            bool is_input = device.direction == Direction.INPUT;
            Gtk.ListStore list_store =
                is_input ? source_list_store : sink_list_store;

            Gtk.TreeIter ? iter = find_device_iter (list_store, device);
            if (iter == null) return;
            list_store.set (iter,
                            DeviceColumns.COLUMN_KEY, device.get_current_hash_key (),
                            DeviceColumns.COLUMN_DEVICE, device,
                            DeviceColumns.COLUMN_ICON, device.icon_name + "-symbolic",
                            DeviceColumns.COLUMN_NAME, device.get_display_name (),
                            -1);

            // Change UI if device is default device
            unowned PulseDevice ? default_device = is_input
                ? this.default_source : this.default_sink;
            if (default_device == null || !device.cmp (default_device)) return;

            Gtk.ComboBox combo_box;
            Gtk.ToggleButton toggle;
            Gtk.Scale slider;
            if (is_input) {
                combo_box = input_combo_box;
                toggle = input_mute_toggle;
                slider = input_slider;
            } else {
                combo_box = output_combo_box;
                toggle = output_mute_toggle;
                slider = output_slider;
            }

            if (device.direction == PulseAudio.Direction.OUTPUT) {
                if (device.is_bluetooth && device.has_card) {
                    output_profile_row.set_visible (true);
                    set_device_profiles (device);
                } else {
                    output_profile_row.set_visible (false);
                    profile_combo_box.changed.disconnect (profile_combo_box_changed);
                    profile_list_store.clear ();
                    profile_combo_box.changed.connect (profile_combo_box_changed);
                }
            }

            // Set active in combo_box without calling its changed signal
            combo_box.changed.disconnect (combo_box_changed);
            combo_box.set_active_iter (iter);
            combo_box.changed.connect (combo_box_changed);
            // Set mute state
            toggle.set_active (device.is_muted);
            // Set volume
            slider.set_value (device.volume);
        }

        private void device_added (PulseDevice device) {
            bool is_input = device.direction == Direction.INPUT;
            Gtk.ListStore list_store =
                is_input ? source_list_store : sink_list_store;

            Gtk.TreeIter iter;
            list_store.append (out iter);
            list_store.set (
                iter,
                DeviceColumns.COLUMN_KEY, device.get_current_hash_key (),
                DeviceColumns.COLUMN_DEVICE, device,
                DeviceColumns.COLUMN_ICON, device.icon_name + "-symbolic",
                DeviceColumns.COLUMN_NAME, device.get_display_name (),
                -1);
            (is_input ? input_group : output_group).set_sensitive (true);
        }

        private void device_removed (PulseDevice device) {
            bool is_input = device.direction == Direction.INPUT;
            Gtk.ListStore list_store =
                is_input ? source_list_store : sink_list_store;

            Gtk.TreeIter ? iter = find_device_iter (list_store, device);
            if (iter == null) return;
            list_store.remove (ref iter);
            if (list_store.iter_n_children (null) == 0) {
                (is_input ? input_group : output_group).set_sensitive (false);
            }
        }

        /*
         * Default Sink/Source
         */

        private void default_device_changed (PulseDevice device) {
            if (device == null) return;
            switch (device.direction) {
                case Direction.INPUT:
                    this.default_source = device;
                    break;
                case Direction.OUTPUT:
                    this.default_sink = device;
                    break;
            }
        }

        /*
         * Active Sinks
         */

        /** Sorts by each device HashMap id */
        private int active_sinks_list_store_sort (Gtk.ListBoxRow a, Gtk.ListBoxRow b) {
            uint32 a_id = ((SinkInputRow) a).sink_input.index;
            uint32 b_id = ((SinkInputRow) b).sink_input.index;
            if (a_id == b_id) return 0;
            return a_id < b_id ? -1 : 1;
        }

        /** Updates the correct `SinkInputRow` with new information */
        private void active_sink_change (PulseSinkInput sink) {
            Functions.iter_listbox_children<Gtk.Widget> (levels_listbox, (row) => {
                if (row == null || !(row is SinkInputRow)) return false;
                var s = (SinkInputRow) row;
                if (s.sink_input.cmp (sink)) {
                    s.update (sink);
                    return true;
                }
                return false;
            });
        }

        /** Adds a new `SinkInputRow` */
        private void active_sink_added (PulseSinkInput sink) {
            levels_listbox.append (new SinkInputRow (sink, client));
            sink_inputs_group.set_sensitive (true);
        }

        /** Removes the correct `SinkInputRow` */
        private void active_sink_removed (PulseSinkInput sink) {
            int count = 0;
            Functions.iter_listbox_children<Gtk.Widget> (levels_listbox, (row) => {
                if (row == null || !(row is SinkInputRow)) return false;
                var s = (SinkInputRow) row;
                count++;
                if (s.sink_input.cmp (sink)) {
                    levels_listbox.remove (row);
                    return true;
                }
                return false;
            });
            if (count == 0) {
                sink_inputs_group.set_sensitive (false);
            }
        }
    }
}
