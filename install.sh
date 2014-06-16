#!/bin/bash

cp -r release /opt/pomodorino/
cp pomodorino.desktop /usr/share/applications/
cp schemas/org.thomashc.pomodorino.gschema.xml /usr/share/glib-2.0/schemas/
glib-compile-schemas /usr/share/glib-2.0/schemas/