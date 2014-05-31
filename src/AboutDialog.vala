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
