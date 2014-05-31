/*
Copyright 2014, Thomas Chace.
All rights reserved.
*/

using Gtk; // For the GUI.

public class AboutPomodorino : Gtk.AboutDialog { //Granite.Widgets.AboutDialog {
    // Dialog window to add tasks.
    
    public AboutPomodorino() {
        this.icon = new Gdk.Pixbuf.from_file("tomato.png");
        this.authors = {"Thomas Chace"};
		this.program_name = "Pomodorino";
		this.copyright = "Copyright 2014 Thomas Chace";
		this.comments = "To do list application with timer implementing aspects of the Pomodoro time management system.";
		this.version = "0.5";
		this.license = "All Rights Reserved.";
		this.website = "http://tchace.info/projects/pomodorino/";
		this.website_label = "tchace.info/projects/pomodorino/";
		this.response.connect ((response_id) => {
		if (response_id == Gtk.ResponseType.CANCEL || response_id == Gtk.ResponseType.DELETE_EVENT) {
			this.hide_on_delete ();
		    }
	    });
    }
}
