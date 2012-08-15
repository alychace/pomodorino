/*
Copyright 2012, Thomas Chace.
All rights reserved.
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
        
        this.border_width = 5;
        this.title = "Add Task";
        
        this.add_button(Stock.CLOSE, ResponseType.CLOSE);
        this.add_button(Stock.ADD, ResponseType.ACCEPT);
        
        content.pack_start(hbox, false, true, 0);
        hbox.pack_start(this.entry);
    }
}
