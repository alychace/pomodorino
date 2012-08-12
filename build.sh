#1/bin/bash

cp src/org.thomashc.pomodoro.gschema.xml /usr/share/glib-2.0/schemas/
glib-compile-schemas /usr/share/glib-2.0/schemas/

valac --pkg gtk+-3.0 --pkg gio-2.0 src/pomodoro.vala -o bin/pomodoro
