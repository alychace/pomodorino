#1/bin/bash

mkdir -p bin/

PWD=`pwd`
FLAGS="--pkg libnotify --pkg gtk+-3.0 --pkg gio-2.0 --pkg gee-1.0 --pkg granite"
FILES="src/*.vala"
BINARY="bin/pomodorino"

sudo cp src/org.thomashc.pomodorino.gschema.xml /usr/share/glib-2.0/schemas/
sudo glib-compile-schemas /usr/share/glib-2.0/schemas/

valac $FLAGS -X -DGETTEXT_PACKAGE=pomodorino $FILES -o $BINARY
cd locale/es_AR/LC_MESSAGES/
msgfmt --check --verbose -o pomodorino.mo pomodorino.po

cd $PWD