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
using Gee; // For fancy and useful things like HashSet.
using Granite.Widgets;
using GLib;

public class TaskList : Window {
    // Main Window

    int pos = 0;
    public AddTask dialog; // We need a dialog to add new tasks.
    public Timer timer;
    public TreeIter iter; // Treeview iter
    public ListStore store; // See above.
    public TreeView tree;
    public Toolbar toolbar;
    public string current; // The currently selected task.
    
    enum Column {
        PRIORITY,
        TASK,
        DATE,
    }
    
    public TaskList() {
        this.current = "||||";
        
        //Gtk.Settings.get_default().set("gtk-application-prefer-dark-theme", true);
        this.dialog = new AddTask(); // Makes a dialog window for adding tasks.
        this.dialog.title = "Add Task"; // Set the title here for localisation.
        this.dialog.set_transient_for(this); // Makes it a modal dialog.
        
        this.window_position = WindowPosition.CENTER; // Center the window on the screen.
        set_default_size(300, 325);

        try {
            // Load the window icon.
            this.icon = new Gdk.Pixbuf.from_file("/opt/pomodorino/images/logo.png");
        } catch (Error e) {
            // If it can't find the logo, the app exits and reports an error.
            stdout.printf("Error: %s\n", e.message);
        }
    }

    void on_changed (Gtk.TreeSelection selection) {
        // Makes sure we know what's currently selected in the Treeview.
        Gtk.TreeModel model;
        Gtk.TreeIter iter;
        string task;
        string date;
        string priority;

        if (selection.get_selected (out model, out iter)) {
            model.get (iter,
                            Column.PRIORITY, out priority,
                            Column.TASK, out task,
                            Column.DATE, out date);
            this.current = task + "||" + priority + "||" + date;
        }
    }
    
    public void new_task(string task) {
        string[] task_data = task.split("||");
        
        var name = task_data[0];
        var date = task_data[2];
        var priority = task_data[1];
        // Adds a new task to the main window and to the backend.
        this.store.append(out this.iter);
        this.store.set(this.iter, 0, priority, 1, name, 2, date);
    }
    
    public void build_ui() {
        // Starts out by setting up the HeaderBar and buttons.
        //toolbar = new HeaderBar();
        toolbar = new Toolbar();
        toolbar.orientation = Gtk.Orientation.HORIZONTAL;
        toolbar.get_style_context().add_class(STYLE_CLASS_PRIMARY_TOOLBAR);
        this.title = "Pomodorino - Tasks";
        //toolbar.show_close_button = true; // Makes sure the user has a close button available.
        //this.set_titlebar(toolbar);
        //toolbar.title = "Tasks";
        //toolbar.subtitle = "Pomodorino";
        
        // Then we get the TreeView set up.
        this.tree = new TreeView();
        this.tree.set_rules_hint(true);
        this.tree.reorderable = true;
        this.store = new ListStore(3, typeof(string), typeof(string), typeof(string));
        this.tree.set_model(this.store);

        // Inserts our columns.
        this.tree.insert_column(get_column(""), -1);
        this.tree.insert_column(get_column("Name"), -1);
        this.tree.insert_column(get_column("Due"), -1);

        // Makes sure we know when the selection changes.
        var selection = this.tree.get_selection();
        selection.changed.connect(this.on_changed);
    }
    
    TreeViewColumn get_column (string title) {
        // This pain in the ass lets us add text to TreeView entries.
        var col = new TreeViewColumn();
        col.title = title;
        col.sort_column_id = this.pos;

        var crt = new CellRendererText();
        col.pack_start(crt, false);
        col.add_attribute(crt, "text", this.pos++);

        return col;
    }
}

