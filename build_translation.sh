xgettext --language=C --keyword=_ --escape --sort-output -o pomodorino.pot src/*.vala
msginit -l es_AR -o locale/es_AR/LC_MESSAGES/pomodorino.po -i pomodorino.pot
