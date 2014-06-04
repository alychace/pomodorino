/*
    Todo list application drawing inspiration from the pomodoro technique
    Copyright (C) 2014  Thomas Chace

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

public class Timer : Dialog {
    // Dialog window to add tasks.

    public ProgressBar progress_bar; // Text box.
    public Label label;
    string task;
    
    public Timer(string current) {
        this.task = current;
        this.icon = new Gdk.Pixbuf.from_file("new-tomato2.png");
        // Let's set the interface up.
        Notify.init("Pomodorino");
        var content = this.get_content_area() as Box;
        var vbox = new Box(Orientation.VERTICAL, 20);
        this.label = new Gtk.Label(current + "\nYou have 25 minutes. Get to work!");
        this.progress_bar = new ProgressBar();
        
        this.border_width = 45;
        this.title = "25 minutes remaining...";
        
        this.add_button(Stock.CANCEL, ResponseType.CANCEL);
        //this.add_button(Stock.ADD, ResponseType.ACCEPT);
        content.pack_start(vbox, false, true, 0);
        vbox.pack_start(label);
        vbox.pack_start(this.progress_bar);
    }
    
    public void set_text(string x) {
        this.progress_bar.set_text(x);
    }
    
    public void fill() {
    // Fill the bar:
		GLib.Timeout.add (30000, () => {
			// Get the current progress:
			// (0.0 -> 0%; 1.0 -> 100%)
			double progress = this.progress_bar.get_fraction();

			// Update the bar:
			progress = progress + 0.02;
			progress_bar.set_fraction(progress);
			double remaining = 25 - (progress * 25);
			this.title = remaining.to_string() + " minutes remaining...";
            this.label.label = this.task + "\n" + this.title;

            if (remaining == 5.0) {
                var notification = new Notification(this.task, this.title, "dialog-information");
                notification.show();
            }
            if (remaining == 10.0) {
                var notification = new Notification(this.task, this.title, "dialog-information");
                notification.show();
            }
            if (remaining == 15.0) {
                var notification = new Notification(this.task, this.title, "dialog-information");
                notification.show();
            }
            if (remaining == 20.0) {
                var notification = new Notification(this.task, this.title, "dialog-information");
                notification.show();
            }
            if (remaining == 25.0) {
                var notification = new Notification(this.task, this.title, "dialog-information");
                notification.show();
            }

			// Repeat until 100%
			return progress < 1.0;
		});
    }
}
