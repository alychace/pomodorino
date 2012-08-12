/*
Copyright 2012, Thomas Chace.
All rights reserved.
*/

using Gtk; // For the GUI.
using Gee; // For fancy and useful things like HashSet.

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

public class Pomodoro : Window {
    // Main Window

    int pos = 0;
    private AddTask dialog; // We need a dialog to add new tasks.
    private TreeIter iter; // Pain in the ass for the TreeView.
    private ListStore store; // See above.
    private HashSet<string> tasks; // Far superior than string[], more flexible(even with conversion).
    private GLib.Settings settings; // DConf.
    public Pomodoro () {
        this.tasks = new HashSet<string>(); // For some reason this magic makes everything work.
        this.settings = new GLib.Settings("org.thomashc.pomodoro");
        this.dialog = new AddTask(); // Makes a dialog window for adding tasks.
        this.dialog.response.connect(dialog_response);
        
        this.title = "Pomo D'Oro";
        this.window_position = WindowPosition.CENTER;
        set_default_size(400, 300);
        
        build_ui(); // For great organisation.
        
        load_config(); // Loads the tasks from DConf.
        remove_task("Take a walk"); // Testing
    }
    
    private void load_config() {
        // Loads tasks and configuration from DConf.
        var saved_tasks = this.settings.get_strv("tasks");
        foreach (string i in saved_tasks) {
            new_task(i);
        }
    }

    private void save_config() {
        // Converts the HashSet to a string[], then saves it to DConf.
        string[] saved_tasks = {};
        foreach (string s in this.tasks) {
            saved_tasks += s;
        }
        this.settings.set_strv("tasks", saved_tasks);
    }
    
    private void new_task(string name) {
        // Adds a new task to the main window and the configuration.
        this.tasks.add(name);
        this.store.append(out this.iter);
        this.store.set(this.iter, 0, "", 1, name);
        save_config(); // Saves our work.
    }
    
    private void remove_task(string name) {
        // Deletes a task from the main window and the configuration.
        this.tasks.remove(name);
        this.store.clear();
        // Time to reload, baby.
        save_config();
        load_config();
    }
    
    private void dialog_response(Dialog source, int response_id) {
        // This makes sure we can interface with our AddTask() dialog.
        switch(response_id) {
        case ResponseType.ACCEPT:
            string text = this.dialog.entry.text;
            new_task(text);
            this.dialog.hide(); // Saves it for later use.
            break;
        case ResponseType.CLOSE:
            this.dialog.hide(); // Saves it for later use.
            break;
        }
    }
    
    private void build_ui() {
        // Starts out by setting up the toolbar and toolbuttons.
        var toolbar = new Toolbar();
        toolbar.get_style_context().add_class(STYLE_CLASS_PRIMARY_TOOLBAR);
        
        var new_button = new ToolButton.from_stock(Stock.NEW);
        toolbar.add(new_button);
        new_button.clicked.connect(this.dialog.show_all);
        
        var delete_button = new ToolButton.from_stock(Stock.DELETE);
        toolbar.add(delete_button);
        
        // Then we get the TreeView set up.
        var tree_view = new TreeView();
        tree_view.set_rules_hint(true);
        
        this.store = new ListStore(2, typeof(string), typeof(string));
        tree_view.set_model(this.store);

        // Inserts our columns.
        tree_view.insert_column(get_column ("Status"), -1);
        tree_view.insert_column(get_column ("Name"), -1);

        // Scrolling is nice.
        var scroll = new ScrolledWindow (null, null);
        scroll.set_policy(PolicyType.AUTOMATIC, PolicyType.AUTOMATIC);
        scroll.add(tree_view);

        // Time to put everything together.
        var vbox = new Box (Orientation.VERTICAL, 0);
        vbox.pack_start(toolbar, false, true, 0);
        vbox.pack_start(scroll, true, true, 0);
        add(vbox);
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

int main (string[] args) {
        // Let's start up Gtk.
        Gtk.init(ref args);

        // Then let's start the main window.
        var window = new Pomodoro(); 
        window.destroy.connect(Gtk.main_quit);
        window.show_all();

        Gtk.main();
        return 0;
}
