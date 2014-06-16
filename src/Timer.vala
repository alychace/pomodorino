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
    string task;

    public Timer(string current) {
        this.progress = 0;
        this.window_position = WindowPosition.CENTER; // Center the window on the screen.
        this.set_default_size(400, 425);
        this.task = current;
        try {
            this.icon = new Gdk.Pixbuf.from_file("images/logo.png");
        } catch (Error e) {
            stdout.printf("Error: %s\n", e.message);
        }
        
        // Let's set the interface up.
        Notify.init("Pomodorino");
        var vbox = new Box(Orientation.VERTICAL, 20);
        var task_label = new Gtk.Label(current + "\n");
        this.label = new Gtk.Label("<span font_desc='60.0'>25:00</span>");
        this.label.set_use_markup(true);
        this.label.set_line_wrap(true);
        
        //this.border_width = 12;
        this.title = "1500 seconds remaining";
        
        this.add(vbox);
        vbox.pack_start(task_label);
        vbox.pack_start(label);
    }

    private string seconds_to_time(int number) {
        var minutes = number / 60;
        var seconds = number % 60;
        var seconds_string = "";
        if (seconds < 10) {
            seconds_string = "0" + seconds.to_string();
        } else {
            seconds_string = seconds.to_string();
        }
        return minutes.to_string() + ":" + seconds_string;
    }
    
    public void fill() {
        this.running = true;
        // Fill the bar:
		GLib.Timeout.add(1000, () => {

			// Update the bar:
			this.progress = this.progress + 1;
			int remaining = 1500 - this.progress;
			this.title = this.seconds_to_time(remaining) + " remaining";
            this.label.label = "<span font_desc='60.0'>" + this.seconds_to_time(remaining) + "</span>";
            var notification = new Notify.Notification(this.task, this.title, "dialog-information");

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
			return progress < 1500;
		});
    }
}
