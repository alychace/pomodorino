/*
Copyright 2012-2014, Thomas Chace.
All rights reserved.
*/

using Gee; // For fancy and useful things like HashSet.
using Gtk;

public class TomatoBase : Object {
    // Backend

    public ArrayList<string> tasks; // Far superior than string[], more flexible(even with conversion).
    private GLib.Settings settings; // DConf.
    
    public TomatoBase () {
        this.tasks = new ArrayList<string>(); // For some reason this magic makes everything work.
        this.settings = new GLib.Settings("org.thomashc.pomodorino");
        
    }
    
    public void load() {
        // Loads tasks and configuration from DConf.
        var saved_tasks = this.settings.get_strv("tasks");
        foreach (string i in saved_tasks) {
            add(i);
        }
    }

    public void save() {
        // Converts the HashSet to a string[], then saves it to DConf.
        string[] saved_tasks = {};
        foreach (string s in this.tasks) {
            saved_tasks += s;
        }
        this.settings.set_strv("tasks", saved_tasks);
    }
    
    public void add(string name) {
        // Adds a new task to the main window and the configuration.
        this.tasks.add(name);
    }
    
    public void remove(string name) {
        // Deletes a task from the main window and the configuration.
        this.tasks.remove(name);
    }   
}
