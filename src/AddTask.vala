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

public class AddTask : Dialog {
    // Dialog window to add tasks.

    public Entry entry; // Text box.
    
    public AddTask() {
        // Let's set the interface up.
        var content = this.get_content_area() as Box;
        var hbox = new Box(Orientation.HORIZONTAL, 20);
        this.entry = new Entry();
        this.modal = true;
        
        this.border_width = 5;
        this.title = "Add Task";
        
        this.add_button("_Close", ResponseType.CLOSE);
        var accept_button = add_button("_Add", ResponseType.ACCEPT);
        this.entry.changed.connect (() => {
            accept_button.sensitive = (this.entry.text != "");
        });
        accept_button.sensitive = false;
        
        content.pack_start(hbox, false, true, 0);
        hbox.pack_start(this.entry);
    }
}
