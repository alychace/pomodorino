/*
Copyright 2014, Thomas Chace.
All rights reserved.
*/

using Gtk; // For the GUI.

public class Timer : Dialog {
    // Dialog window to add tasks.

    public ProgressBar progress_bar; // Text box.
    public Label label;
    
    public Timer() {
        // Let's set the interface up.
        var content = this.get_content_area() as Box;
        var vbox = new Box(Orientation.VERTICAL, 20);
        this.label = new Gtk.Label("You have 25 minutes. Get to work!");
        this.progress_bar = new ProgressBar();
        
        this.border_width = 45;
        this.title = "Timer";
        
        this.add_button(Stock.CANCEL, ResponseType.CANCEL);
        //this.add_button(Stock.ADD, ResponseType.ACCEPT);
        content.pack_start(vbox, false, true, 0);
        vbox.pack_start(label);
        vbox.pack_start(this.progress_bar);
        this.response.connect ((response_id) => {
        if (response_id == Gtk.ResponseType.CANCEL || response_id == Gtk.ResponseType.DELETE_EVENT) {
			this.destroy();
		    }
	    });
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
			var percent = progress * 100;
			int integer = (int)progress;
			int remaining = 25 - (integer * 25);
			this.title = remaining.to_string() + " minutes remaining";
			
			stdout.printf ("Hello World\n");

			// Repeat until 100%
			return progress < 1.0;
		});
    }
}
