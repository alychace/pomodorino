#1/bin/bash

rm -r release
mkdir -p release
mkdir -p release/images

FLAGS="--pkg libnotify --pkg appindicator3-0.1 --pkg gtk+-3.0 --pkg gio-2.0 --pkg gee-1.0 --pkg granite"
FILES="src/*.vala"
BINARY="release/pomodorino"

#sudo cp schemas/org.thomashc.pomodorino.gschema.xml /usr/share/glib-2.0/schemas/
#sudo glib-compile-schemas /usr/share/glib-2.0/schemas/
glib-compile-schemas ./schemas/
# -X -DGETTEXT_PACKAGE=pomodorino
valac $FLAGS $FILES -o $BINARY
#cd locale/es_AR/LC_MESSAGES/
#msgfmt --check --verbose -o pomodorino.mo pomodorino.po

#cd ../../../

#cp -r locale release/
cp -r logo.png release/images/logo.png
cp LICENSE release/LICENSE
cp logo.png.LICENSE release/images/logo.png.LICENSE
cp -r schemas release/

#rm locale/es_AR/LC_MESSAGES/pomodorino.mo
rm schemas/gschemas.compiled
