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
    private File settings_file;
    
    public TomatoBase () {
        this.tasks = new ArrayList<string>(); // For some reason this magic makes everything work.
        this.settings_file = File.new_for_path(GLib.Environment.get_variable("HOME") + "/.pomodorino_tasks");
        if (!this.settings_file.query_exists()) {
            stderr.printf("File '%s' doesn't exist.\n", this.settings_file.get_path ());
        } else {
            //this.settings_file.create();
        }
    }
    
    public void load() {
        // Open file for reading and wrap returned FileInputStream into a
        // DataInputStream, so we can read line by line
        try {
            var dis = new DataInputStream (this.settings_file.read());
            string line;
            // Read lines until end of file (null) is reached
            while ((line = dis.read_line(null)) != null) {
                add(line);
            } 
        } catch (Error e) {
            stderr.printf("%s", e.message);
        }
    }

    public void save() {
        try {
            if (this.settings_file.query_exists ()) {
                this.settings_file.delete();
            }

            var dos = new DataOutputStream (this.settings_file.create (FileCreateFlags.REPLACE_DESTINATION));
            foreach (string s in this.tasks) {
                dos.put_string(s + "\n");
            }
        } catch (Error e) {
            stderr.printf("%s", e.message);
        }
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
