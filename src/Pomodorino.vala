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

public class Pomodorino {
    private TaskList window;
    private TaskStore backend;

    public Pomodorino (string[] args) {
        var launcher = Unity.LauncherEntry.get_for_desktop_id("pomodorino.desktop");
        launcher.count_visible = true;

        this.backend = new TaskStore(); // Backend for saving/loading files.
        window = new TaskList();
        build_ui();
        load();
        window.show_all();
        window.dialog.response.connect(addtask_response); // Set the dialog's button to respond with our addtask method.

        window.destroy.connect(quit); // Close button = app exit.

    }

    public void addtask_response(Dialog source, int response_id) {
        // Sets up the signals for the AddTask() dialog.
        switch(response_id) {
            case ResponseType.ACCEPT:
                var task = window.dialog.name_entry.text + "||" + window.dialog.priority_entry.text + "||" + window.dialog.date_entry.text;
                window.new_task(task);
                this.backend.add(task);
                window.dialog.hide(); // Saves it for later use.
                window.dialog.name_entry.set_text("");
                break;
            case ResponseType.CLOSE:
                window.dialog.hide(); // Saves it for later use.
                break;
        }
    }

    private void build_ui() {
        window.build_ui();

        // Add a task.
        Image new_img = new Image.from_icon_name ("document-new", Gtk.IconSize.SMALL_TOOLBAR);
        ToolButton new_button = new ToolButton (new_img, null);
        window.toolbar.pack_start(new_button);
        new_button.clicked.connect(window.dialog.show_all);
        
        // Delete a task.
        Image delete_img = new Image.from_icon_name ("edit-delete", Gtk.IconSize.SMALL_TOOLBAR);
        var delete_button = new ToolButton(delete_img, null);
        var delete_style = delete_button.get_style_context ();
        delete_style.add_class("destructive-action");
        window.toolbar.pack_start(delete_button);
        delete_button.clicked.connect(remove_task);

        // Start a task.
        Image start_img = new Image.from_icon_name("media-playback-start", IconSize.SMALL_TOOLBAR);
        var start_button = new ToolButton(start_img, null);
        window.toolbar.pack_end(start_button);
        start_button.clicked.connect(start_timer);

        var separator = new Gtk.SeparatorToolItem();
        
        separator.draw = false;
        separator.set_expand(true);
        window.toolbar.pack_end(separator);

        // Menu button
        var menu = new Gtk.Menu();
        Gtk.MenuItem about = new Gtk.MenuItem.with_label("About");
        menu.add(about);
        about.activate.connect (() => {
            Gtk.AboutDialog about_dialog = new AboutPomodorino();
            //Gtk.AboutDialog about_dialog = new AboutPomodorino();
            try {
                about_dialog.logo = new Gdk.Pixbuf.from_file("/opt/pomodorino/images/logo.png");
            } catch (Error e) {
                stdout.printf("Error: %s", e.message);
            }
              about_dialog.show();
        });
        var menu_button = new AppMenu(menu);
        window.toolbar.pack_end(menu_button);
        
        // Scrolling is nice.
        var scroll = new ScrolledWindow(null, null);
        scroll.set_policy(PolicyType.AUTOMATIC, PolicyType.AUTOMATIC);
        scroll.add(window.tree);

        // Time to put everything together.
        var vbox = new Box(Orientation.VERTICAL, 0);
        vbox.pack_start(window.toolbar, false, true, 0);
        vbox.pack_start(scroll, true, true, 0);
        window.add(vbox);
    }

    public void start_timer() {
        save();
        if (window.current in this.backend.tasks) {
            var timer = new Timer();
            timer.set_transient_for(window); // Makes it a modal dialog.
            timer.destroy.connect(() => {
                timer.running = false;
            });
            
            // Starts a timer for the current task.
            timer.task = window.current.split("||")[0];
            timer.show_all();
            timer.start();
        } else {
            // If the current task isn't in the backend yet (AKA: It's been deleted), prompt the user.
            Gtk.MessageDialog msg = new Gtk.MessageDialog (this.window, Gtk.DialogFlags.MODAL, Gtk.MessageType.WARNING, Gtk.ButtonsType.OK, "Please select a task to start.");
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
    
    public void show() {
        build_indicator();
        window.show_all();
    }

    private void load() {
        // Loads tasks from DConf.
        this.backend.load();
        foreach (string task in this.backend.tasks) {
            window.new_task(task);
        }
    }

    public void save() {
        // Saves the tasks before quitting the app.
        var tasks = new ArrayList<string>();
        Gtk.TreeModelForeachFunc add_to_tasks = (model, path, iter) => {
            GLib.Value name;
            GLib.Value date;
            GLib.Value priority;

            window.store.get_value(iter, 0, out date);
            window.store.get_value(iter, 1, out priority);
            window.store.get_value(iter, 2, out name);
            tasks.add((string) name + "||" + (string) date + "||" + (string) priority);
            return false;
        };
        window.store.foreach(add_to_tasks);
        backend.tasks = tasks;
        backend.save();
    }

    private void remove_task() {
        // Deletes a task from the Treeview and the configuration.
        this.backend.remove(window.current);
        window.remove_task();
        load();
    }

    private void quit() {
        save();
        Gtk.main_quit();
    }
    private void build_indicator() {
        var indicator = new AppIndicator.Indicator("Pomodorino", "/opt/pomodorino/images/logo.png",
                                      AppIndicator.IndicatorCategory.APPLICATION_STATUS);

        indicator.set_status(AppIndicator.IndicatorStatus.ACTIVE);

        var menu = new Gtk.Menu();

        // Add Timer Button
        var timer_item = new Gtk.MenuItem.with_label("Start Timer");
        timer_item.activate.connect(() => {
            indicator.set_status(AppIndicator.IndicatorStatus.ATTENTION);
            start_timer();
        });
        timer_item.show();
        menu.append(timer_item);

        var show_item = new Gtk.MenuItem.with_label("Hide");
        show_item.show();
        show_item.activate.connect(() => {
            if (window.visible) {
                show_item.label = "Show";
                window.hide();
            } else {
                window.show_all();
                show_item.label = "Hide";
            }

        });
        menu.append(show_item);

        // Add Quit button
        var item = new Gtk.MenuItem.with_label("Quit");
        item.show();
        item.activate.connect(() => {
            quit();
        });
        menu.append(item);

        indicator.set_menu(menu);
    }

}

void main (string[] args) {
    // Let's start up Gtk.
    Gtk.init(ref args);

    // Then let's start the main window.
    var window = new Pomodorino(args); 
    window.show();

    Gtk.main();
}
