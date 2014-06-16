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

    public ProgressBar progress_bar; // Text box.
    public Label label;
    public bool running;
    string task;

    public Timer(string current) {
        set_default_size(400, 425);
        this.task = current;
        try {
            this.icon = new Gdk.Pixbuf.from_file("images/logo.png");
        } catch (Error e) {
            stdout.printf("Error: %s\n", e.message);
        }
        
        // Let's set the interface up.
        Notify.init("Pomodorino");
        var vbox = new Box(Orientation.VERTICAL, 20);
        this.label = new Gtk.Label(current + "\n" + "<span font_desc='59.0'>25</span>");
        this.label.set_use_markup(true);
        this.label.set_line_wrap(true);
        this.progress_bar = new ProgressBar();
        
        this.border_width = 12;
        this.title = "25 minutes remaining";
        
        this.add(vbox);
        vbox.pack_start(label);
        vbox.pack_end(this.progress_bar);
    }
    
    public void fill() {
        this.running = true;
        // Fill the bar:
		GLib.Timeout.add(30000, () => {
			// Get the current progress:
			// (0.0 -> 0%; 1.0 -> 100%)
			double progress = this.progress_bar.get_fraction();

			// Update the bar:
			progress = progress + 0.02;
			progress_bar.set_fraction(progress);
			double remaining = 25 - (progress * 25);
			this.title = remaining.to_string() + " minutes remaining";
            this.label.label = this.task + "\n" + "<span font_desc='59.0'>" + remaining.to_string() + "</span>";
            var notification = new Notify.Notification(this.task, this.title, "dialog-information");

            if (remaining == 5.0 && this.running == true) {
                try {
                    notification.show();
                } catch (Error e) {
                    error ("Error: %s", e.message);
                }
            }
            else if (remaining == 10.0 && this.running == true) {
                try {
                    notification.show();
                } catch (Error e) {
                    error ("Error: %s", e.message);
                }
            }
            else if (remaining == 15.0 && this.running == true) {
                try {
                    notification.show();
                } catch (Error e) {
                    error ("Error: %s", e.message);
                }
            }
            else if (remaining == 20.0 && this.running == true) {
                try {
                    notification.show();
                } catch (Error e) {
                    error ("Error: %s", e.message);
                }
            }
            else if (remaining == 25.0 && this.running == true) {
                try {
                    notification.show();
                } catch (Error e) {
                    error ("Error: %s", e.message);
                }
            }
			// Repeat until 100%
			return progress < 1.0;
		});
    }
}
