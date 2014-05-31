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
