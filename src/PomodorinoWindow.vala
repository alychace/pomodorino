/*
Copyright 2012-2014, Thomas Chace.
All rights reserved.
*/

using Gtk; // For the GUI.
using Gee; // For fancy and useful things like HashSet.
using Granite.Widgets;

public class Pomodorino : Window {
    // Main Window

    int pos = 0;
    private AddTask dialog; // We need a dialog to add new tasks.
    private Timer timer;
    private TreeIter iter; // Pain in the ass for the TreeView.
    private ListStore store; // See above.
    private TreeView tree;
    private TomatoBase backend;
    private string current;
    
    enum Column {
        STATUS,
        TASK,
    }
    
    public Pomodorino () {
        destroy.connect(quit);
        //Gtk.Settings.get_default().set("gtk-application-prefer-dark-theme", true);
        this.backend = new TomatoBase();
        this.dialog = new AddTask(); // Makes a dialog window for adding tasks.
        this.timer = new Timer();
        this.dialog.response.connect(addtask_response);
        
        this.window_position = WindowPosition.CENTER;
        set_default_size(500, 400);

        this.icon = new Gdk.Pixbuf.from_file("new-tomato2.png");
        
        build_ui(); // For great organisation.
        load();
    }

    void on_changed (Gtk.TreeSelection selection) {
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
        this.timer.set_text(this.current);
    }
    
    private void quit() {
        backend.save();
        Gtk.main_quit();
    }
    
    private void load() {
        // Loads tasks and configuration from DConf.
        backend.load();
        var saved_tasks = backend.tasks;
        foreach (string i in saved_tasks) {
            new_task(i);
        }
    }
    
    private void new_task(string name) {
        // Adds a new task to the main window and the configuration.
        this.store.append(out this.iter);
        this.store.set(this.iter, 0, "TODO:", 1, name);
    }
    
    private void remove_task() {
        // Deletes a task from the main window and the configuration.
        backend.remove(this.current);
        this.store.clear();
        var saved_tasks = backend.tasks;
        foreach (string i in saved_tasks) {
            new_task(i);
        }
    }
    
    private void addtask_response(Dialog source, int response_id) {
        // This makes sure we can interface with our AddTask() dialog.
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
        timer = new Timer();
        timer.show_all();
        timer.fill();
    }
    
    private void build_ui() {
        // Starts out by setting up the toolbar and toolbuttons.
        //var toolbar = new ToolBar();
        var toolbar = new HeaderBar();
        //toolbar.get_style_context().add_class(STYLE_CLASS_PRIMARY_TOOLBAR);
        
        toolbar.show_close_button = true;
        this.set_titlebar(toolbar);
        toolbar.title = "Tasks";
        toolbar.subtitle = "Pomodorino";
        
        Image new_img = new Image.from_icon_name ("document-new", Gtk.IconSize.SMALL_TOOLBAR);
        ToolButton new_button = new ToolButton (new_img, null);
        toolbar.add(new_button);
        new_button.clicked.connect(this.dialog.show_all);
        
        Image delete_img = new Image.from_icon_name ("edit-delete", Gtk.IconSize.SMALL_TOOLBAR);
        var delete_button = new ToolButton(delete_img, null);
        toolbar.add(delete_button);
        delete_button.clicked.connect(remove_task);
        
        var menu = new Gtk.Menu();
        Gtk.MenuItem about = new Gtk.MenuItem.with_label("About");
		    menu.add(about);
		    //Granite.Widgets.AboutDialog about_dialog = new AboutPomodorino();
		    Gtk.AboutDialog about_dialog = new AboutPomodorino();
		    about_dialog.hide();
		    about.activate.connect (() => {
			      about_dialog.show();
		});
        var menu_button = new AppMenu(menu);
        
        toolbar.pack_end(menu_button);
        
        Image start_img = new Image.from_icon_name("media-playback-start", IconSize.SMALL_TOOLBAR);
        var start_button = new ToolButton(start_img, null);
        toolbar.pack_end(start_button);
        start_button.clicked.connect(start_timer);
        
        // Then we get the TreeView set up.
        this.tree = new TreeView();
        this.tree.set_rules_hint(true);
        
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

        var selection = this.tree.get_selection ();
        selection.changed.connect (this.on_changed);
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
    var window = new Pomodorino(); 
    window.show_all();

    Gtk.main();
    return 0;
}
