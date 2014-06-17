/*
    Todo list application drawing inspiration from the pomodoro technique
    Copyright (C) 2014 Thomas Chace

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

using Gtk; // For the GUI.
using Notify;

public class Timer : Window {
    // Dialog window to add tasks.

    public Label label;
    public bool running;
    public int progress;
    private HeaderBar toolbar;
    string task;

    public Timer(string current) {
        this.progress = 0;
        this.window_position = WindowPosition.CENTER; // Center the window on the screen.
        this.set_default_size(400, 425);
        this.task = current;
        try {
            this.icon = new Gdk.Pixbuf.from_file("/opt/pomodorino/images/logo.png");
        } catch (Error e) {
            stderr.printf("Error: %s\n", e.message);
        }
        
        // Let's set the interface up.
        Notify.init("Pomodorino");
        build_ui();
    }

    private void build_ui() {
        toolbar = new HeaderBar();
        toolbar.show_close_button = true; // Makes sure the user has a close button available.
        this.set_titlebar(toolbar);
        toolbar.title = "Pomodorino";

        var vbox = new Box(Orientation.VERTICAL, 20);
        this.label = new Gtk.Label("<span font_desc='60.0'>25:00</span>");
        this.label.set_use_markup(true);
        this.label.set_line_wrap(true);
        
        //this.border_width = 12;
        toolbar.title = "Pomodorino - 25:00";
        
        this.add(vbox);
        
        vbox.pack_start(label);
    }

    private string seconds_to_time(int number) {
        var minutes = number / 60;
        var seconds = number % 60;
        var minutes_string = "";
        var seconds_string = "";

        if (minutes < 10) {
            minutes_string = "0" + minutes.to_string();
        } else {
            minutes_string = minutes.to_string();
        }
        
        if (seconds < 10) {
            seconds_string = "0" + seconds.to_string();
        } else {
            seconds_string = seconds.to_string();
        }
        return minutes.to_string() + ":" + seconds_string;
    }

    public void short_break() {
        this.running = true;
        var launcher = Unity.LauncherEntry.get_for_desktop_id("pomodorino.desktop");
        launcher.count_visible = true;
        // Fill the bar:
        GLib.Timeout.add(1000, () => {

            // Update the bar:
            this.progress = this.progress + 1;
            int remaining = 300 - this.progress;
            toolbar.title = "Pomodorino - " + this.seconds_to_time(remaining);
            toolbar.subtitle = "Short Break";
            this.label.label = "<span font_desc='60.0'>" + this.seconds_to_time(remaining) + "</span>";
            var notification = new Notify.Notification(this.task, this.seconds_to_time(remaining), "dialog-information");

            // Repeat until 100%
            if (progress == 300) {
                // If the current task isn't in the backend yet (AKA: It's been deleted), prompt the user.
                Gtk.MessageDialog msg = new Gtk.MessageDialog(this, Gtk.DialogFlags.MODAL, Gtk.MessageType.QUESTION, Gtk.ButtonsType.OK, "Break complete.");
                msg.response.connect ((response_id) => {
                    switch (response_id) {
                        case Gtk.ResponseType.OK:
                            msg.destroy();
                            break;
                        case Gtk.ResponseType.DELETE_EVENT:
                            msg.destroy();
                            break;
                    }
                });
                msg.show();
            }
            return progress < 1500;
        }); 
    }
    
    public void start() {
        this.running = true;
        var launcher = Unity.LauncherEntry.get_for_desktop_id("pomodorino.desktop");
        launcher.count_visible = true;
        // Fill the bar:
		GLib.Timeout.add(1000, () => {

			// Update the bar:
			this.progress = this.progress + 1;
			int remaining = 1500 - this.progress;
			toolbar.title = "Pomodorino - " + this.seconds_to_time(remaining);
            toolbar.subtitle = this.task;
            this.label.label = "<span font_desc='60.0'>" + this.seconds_to_time(remaining) + "</span>";
            var notification = new Notify.Notification(this.task, this.seconds_to_time(remaining), "dialog-information");

            if (remaining == 300 && this.running == true) {
                try {
                    notification.show();
                } catch (Error e) {
                    error ("Error: %s", e.message);
                }
            }
            else if (remaining == 600 && this.running == true) {
                try {
                    notification.show();
                } catch (Error e) {
                    error ("Error: %s", e.message);
                }
            }
            else if (remaining == 900 && this.running == true) {
                try {
                    notification.show();
                } catch (Error e) {
                    error ("Error: %s", e.message);
                }
            }
            else if (remaining == 1200 && this.running == true) {
                try {
                    notification.show();
                } catch (Error e) {
                    error ("Error: %s", e.message);
                }
            }
            else if (remaining == 1500 && this.running == true) {
                try {
                    notification.show();
                } catch (Error e) {
                    error ("Error: %s", e.message);
                }
            }
			// Repeat until 100%
            if (progress == 1500) {
                launcher.count++;
                // If the current task isn't in the backend yet (AKA: It's been deleted), prompt the user.
                Gtk.MessageDialog msg = new Gtk.MessageDialog(this, Gtk.DialogFlags.MODAL, Gtk.MessageType.QUESTION, Gtk.ButtonsType.OK, "Task complete.");
                msg.response.connect ((response_id) => {
                switch (response_id) {
                    case Gtk.ResponseType.OK:
                        msg.destroy();
                        short_break();
                        break;
                    case Gtk.ResponseType.DELETE_EVENT:
                        msg.destroy();
                        break;
                }
                });
                msg.show();
            }
			return progress < 1500;
		});
    }
}
