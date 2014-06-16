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

public class Pomodorino : Window {
    // Main Window

    int pos = 0;
    private AddTask dialog; // We need a dialog to add new tasks.
    private Timer timer;
    private TreeIter iter; // Treeview iter
    private ListStore store; // See above.
    private TreeView tree;
    private TomatoBase backend;
    private string current; // The currently selected task.
    private string pwd;
    
    enum Column {
        STATUS,
        TASK,
    }
    
    public Pomodorino (string[] args) {
        var file = args[0].replace(".", "/");
        this.pwd = GLib.Environment.get_current_dir() + (file.replace(GLib.Path.get_basename(file), ""));
        destroy.connect(quit); // Close button = app exit.
        //Gtk.Settings.get_default().set("gtk-application-prefer-dark-theme", true);
        this.backend = new TomatoBase(); // Backend for saving/loading files.
        this.dialog = new AddTask(); // Makes a dialog window for adding tasks.
        this.dialog.title = "Add Task"; // Set the title here for localisation.
        this.dialog.set_transient_for(this); // Makes it a modal dialog.
        this.dialog.response.connect(addtask_response); // Set the dialog's button to respond with our addtask method.
        
        this.window_position = WindowPosition.CENTER; // Center the window on the screen.
        set_default_size(400, 550);

        try {
            // Load the window icon.
            this.icon = new Gdk.Pixbuf.from_file("images/logo.png");
        } catch (Error e) {
            // If it can't find the logo, the app exits and reports an error.
            stdout.printf("Error: %s\n", e.message);
        }
        
        build_ui(); // Builds the user interface.
        load(); // Load tasks.
    }

    void on_changed (Gtk.TreeSelection selection) {
        // Makes sure we know what's currently selected in the Treeview.
        Gtk.TreeModel model;
        Gtk.TreeIter iter;
        string status;
        string task;

        if (selection.get_selected (out model, out iter)) {
            model.get (iter,
                                   Column.STATUS, out status,
                                   Column.TASK, out task);
            this.current = task;
        }
    }
    
    private void quit() {
        // Saves the tasks before quittingt the app.
        var tasks = new ArrayList<string>();
        Gtk.TreeModelForeachFunc add_to_tasks = (model, path, iter) => {
            GLib.Value cell1;
            GLib.Value cell2;

            this.store.get_value (iter, 0, out cell1);
            this.store.get_value (iter, 1, out cell2);
            tasks.add((string) cell2);
            return false;
        };
        this.store.foreach(add_to_tasks);
        backend.tasks = tasks;
        backend.save();
        Gtk.main_quit();
    }
    
    private void load() {
        // Loads tasks from DConf.
        backend.load();
        var saved_tasks = backend.tasks;
        foreach (string i in saved_tasks) {
            new_task(i);
        }
    }
    
    private void new_task(string name) {
        // Adds a new task to the main window and to the backend.
        this.store.append(out this.iter);
        this.store.set(this.iter, 0, "TODO", 1, name);
    }
    
    private void remove_task() {
        // Deletes a task from the Treeview and the configuration.
        backend.remove(this.current);
        this.store.clear();
        var saved_tasks = backend.tasks;
        foreach (string i in saved_tasks) {
            new_task(i);
        }
    }
    
    private void addtask_response(Dialog source, int response_id) {
        // Sets up the signals for the AddTask() dialog.
        switch(response_id) {
            case ResponseType.ACCEPT:
                string text = this.dialog.entry.text;
                new_task(text);
                this.backend.add(text);
                this.dialog.hide(); // Saves it for later use.
                this.dialog.entry.set_text("");
                break;
            case ResponseType.CLOSE:
                this.dialog.hide(); // Saves it for later use.
                break;
        }
    }
    
    private void start_timer() {
        // Starts a timer for the current task.
        if (this.current in this.backend.tasks) {
            timer = new Timer(this.current);
            timer.response.connect ((response_id) => {
                if (response_id == ResponseType.CANCEL || response_id == ResponseType.DELETE_EVENT || response_id == ResponseType.CLOSE) {
                    this.show_all();
                    timer.running = false;
                    timer.destroy();
                }
            });
            timer.show_all();
            this.hide();
            timer.fill(); // Fill the progress bar.
        }
        else {
            // If the current task isn't in the backend yet (AKA: It's been deleted), prompt the user.
            Gtk.MessageDialog msg = new Gtk.MessageDialog (this, Gtk.DialogFlags.MODAL, Gtk.MessageType.WARNING, Gtk.ButtonsType.OK, "Please select a task to start.");
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
    }

    private void build_indicator() {
        var indicator = new AppIndicator.Indicator("Pomodorino", GLib.Environment.get_current_dir() + "/images/logo.png",
                                      AppIndicator.IndicatorCategory.APPLICATION_STATUS);

        indicator.set_status(AppIndicator.IndicatorStatus.ACTIVE);

        var menu = new Gtk.Menu();

        // Add Timer Button
        var item = new Gtk.MenuItem.with_label("Start Timer");
        item.activate.connect(() => {
            indicator.set_status(AppIndicator.IndicatorStatus.ATTENTION);
            start_timer();
        });
        item.show();
        menu.append(item);

        item = new Gtk.MenuItem.with_label("Visibility");
        item.show();
        item.activate.connect(() => {
            if (this.visible) {
                this.hide();
            } else {
                this.show_all();
            }

        });
        menu.append(item);

        // Add Quit button
        item = new Gtk.MenuItem.with_label("Quit");
        item.show();
        item.activate.connect(() => {
            quit();
        });
        menu.append(item);

        indicator.set_menu(menu);
    }
    
    private void build_ui() {
        build_indicator();
        // Starts out by setting up the HeaderBar and buttons.
        //var toolbar = new Toolbar();
        //toolbar.get_style_context().add_class(STYLE_CLASS_PRIMARY_TOOLBAR);
        var toolbar = new HeaderBar();
        toolbar.show_close_button = true; // Makes sure the user has a close button available.
        this.set_titlebar(toolbar);
        toolbar.title = "Tasks";
        toolbar.subtitle = "Pomodorino";
        
        // Add a task.
        Image new_img = new Image.from_icon_name ("document-new", Gtk.IconSize.SMALL_TOOLBAR);
        ToolButton new_button = new ToolButton (new_img, null);
        toolbar.add(new_button);
        new_button.clicked.connect(this.dialog.show_all);
        
        // Delete a task.
        Image delete_img = new Image.from_icon_name ("edit-delete", Gtk.IconSize.SMALL_TOOLBAR);
        var delete_button = new ToolButton(delete_img, null);
        var delete_style = delete_button.get_style_context ();
        delete_style.add_class("destructive-action");
        toolbar.add(delete_button);
        delete_button.clicked.connect(remove_task);

        // Start a task.
        Image start_img = new Image.from_icon_name("media-playback-start", IconSize.SMALL_TOOLBAR);
        var start_button = new ToolButton(start_img, null);
        toolbar.pack_end(start_button);
        start_button.clicked.connect(start_timer);

        var separator = new Gtk.SeparatorToolItem();
        separator.set_draw (true);
        toolbar.pack_end(separator);
        
        // Menu button
        var menu = new Gtk.Menu();
        Gtk.MenuItem about = new Gtk.MenuItem.with_label("About");
	    menu.add(about);
	    Granite.Widgets.AboutDialog about_dialog = new AboutPomodorino();
	    //Gtk.AboutDialog about_dialog = new AboutPomodorino();
        try {
            about_dialog.logo = new Gdk.Pixbuf.from_file("images/logo.png");
        } catch (Error e) {
            stdout.printf("Error: %s", e.message);
        }
	    about_dialog.hide();
	    about.activate.connect (() => {
		      about_dialog.show();
		});
        var menu_button = new AppMenu(menu);
        toolbar.pack_end(menu_button);
        
        // Then we get the TreeView set up.
        this.tree = new TreeView();
        this.tree.set_rules_hint(true);
        this.tree.reorderable = true;
        this.store = new ListStore(2, typeof(string), typeof(string));
        this.tree.set_model(this.store);

        // Inserts our columns.
        this.tree.insert_column(get_column ("Status"), -1);
        this.tree.insert_column(get_column ("Name"), -1);

        // Scrolling is nice.
        var scroll = new ScrolledWindow (null, null);
        scroll.set_policy(PolicyType.AUTOMATIC, PolicyType.AUTOMATIC);
        scroll.add(this.tree);

        // Time to put everything together.
        var vbox = new Box (Orientation.VERTICAL, 0);
        vbox.pack_start(toolbar, false, true, 0);
        vbox.pack_start(scroll, true, true, 0);
        add(vbox);

        // Makes sure we know when the selection changes.
        var selection = this.tree.get_selection();
        selection.changed.connect(this.on_changed);
    }
    
    TreeViewColumn get_column (string title) {
        // This pain in the ass lets us add text to TreeView entries.
        var col = new TreeViewColumn ();
        col.title = title;
        col.sort_column_id = this.pos;

        var crt = new CellRendererText ();
        col.pack_start (crt, false);
        col.add_attribute (crt, "text", this.pos++);

        return col;
    }
}

void main (string[] args) {
    // Let's start up Gtk.
    GLib.Environment.set_variable("GSETTINGS_SCHEMA_DIR", "schemas/", true);
    Gtk.init(ref args);

    // Then let's start the main window.
    var window = new Pomodorino(args); 
    window.show_all();

    Gtk.main();
}
