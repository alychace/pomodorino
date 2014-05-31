#1/bin/bash

sudo cp src/org.thomashc.pomodorino.gschema.xml /usr/share/glib-2.0/schemas/
sudo glib-compile-schemas /usr/share/glib-2.0/schemas/

valac --pkg gtk+-3.0 --pkg gio-2.0 --pkg gee-1.0 --pkg granite src/*.vala -o bin/pomodorino
