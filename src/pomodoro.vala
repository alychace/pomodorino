using Gtk;

public class AddTask : Dialog {

    public Entry entry;
    public AddTask() {
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

    int pos = 0;
    private AddTask dialog;
    private TreeIter iter;
    private ListStore store;
    private string[] tasks;
    private GLib.Settings settings;
    public Pomodoro () {
        this.settings = new GLib.Settings ("org.thomashc.pomodoro");
        this.dialog = new AddTask();
        this.dialog.response.connect(dialog_response);
        
        this.title = "Pomo D'Oro";
        this.window_position = WindowPosition.CENTER;
        set_default_size(400, 300);
        
        var toolbar = new Toolbar();
        toolbar.get_style_context().add_class(STYLE_CLASS_PRIMARY_TOOLBAR);
        
        var new_button = new ToolButton.from_stock(Stock.NEW);
        toolbar.add(new_button);
        new_button.clicked.connect(this.dialog.show_all);
        
        var tree_view = new TreeView();
        tree_view.set_rules_hint(true);
        
        this.store = new ListStore(2, typeof(string), typeof(string));
        tree_view.set_model(this.store);

        tree_view.insert_column(get_column ("Status"), -1);
        tree_view.insert_column(get_column ("Name"), -1);

        var scroll = new ScrolledWindow (null, null);
        scroll.set_policy(PolicyType.AUTOMATIC, PolicyType.AUTOMATIC);
        scroll.add(tree_view);

        var vbox = new Box (Orientation.VERTICAL, 0);
        vbox.pack_start(toolbar, false, true, 0);
        vbox.pack_start(scroll, true, true, 0);
        add(vbox);
        
        load_config();
    }
    
    private void load_config() {
        // Getting keys
        var saved_tasks = this.settings.get_strv("tasks");
        foreach (string i in saved_tasks) {
            new_task(i);
        }
    }

    private void save_config() {
        // Getting keys
        this.settings.set_strv("tasks", tasks);
    }
    
    private void new_task(string name) {
        this.tasks += name;
        this.store.append(out this.iter);
        this.store.set(this.iter, 0, "", 1, name);
        save_config();
    }
    
    private void dialog_response(Dialog source, int response_id) {
        switch(response_id) {
        case ResponseType.ACCEPT:
            string text = this.dialog.entry.text;
            new_task(text);
            this.dialog.hide();
            break;
        case ResponseType.CLOSE:
            this.dialog.hide();
            break;
        }
    }
    
    TreeViewColumn get_column (string title) {
        var col = new TreeViewColumn ();
        col.title = title;
        col.resizable = true;

        col.sort_column_id = this.pos;

        var crt = new CellRendererText ();
        col.pack_start (crt, false);
        col.add_attribute (crt, "text", this.pos++);

        return col;
    }
}

int main (string[] args) {
        Gtk.init(ref args);

        var window = new Pomodoro();
        window.destroy.connect(Gtk.main_quit);
        window.show_all();

        Gtk.main();
        return 0;
}
