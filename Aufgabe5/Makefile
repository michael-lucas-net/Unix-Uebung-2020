# Makefile fuer Quellcode-Dokumentationen
# Michael Lucas - inf102773
# Letzte Aenderung: 08.07.2020

# Beschreibung: Erstellt Quellcode-Dokumentationen aus Shell-Skripten.

# VARIABLES
  # PRETEXT - text prepended to every markdown file (default="# Code Documentation")

# TARGETS
 # all   - default target, does the same as index target
 # index - create all md files, html pages and an index.html
 # html  - create all md files and html pages
 # md    - create all md files
 # help  - display this help and exit
 # clean - remove all generated files

# ==== VARS
PRE_TEXT = \# Code Documentation
SH_OBJECTS = $(wildcard *.sh)
MD_OBJECTS = $(SH_OBJECTS:.sh=.md)
HTML_OBJECTS = $(SH_OBJECTS:.sh=.html)
INDEX_FILE = index.html

# Um tausend Echos zu vermeiden ein define mit dem Text
define showHelp
Makefile to create a code documentation of shell files using markdown.

VARIABLES
  PRETEXT - text prepended to every markdown file (default="# Code Documentation")

TARGETS
  all   - default target, does the same as index target
  index - create all md files, html pages and an index.html
  html  - create all md files and html pages
  md    - create all md files
  help  - display this help and exit
  clean - remove all generated files
endef
export showHelp

# Make soll keine temp.-Dateien loeschen
# -> Ein .SECONDARY ohne Abhängigkeiten deaktiviert das automatische Löschen von Zwischenzielen
.SECONDARY:

# Ruft standardmaessig index auf
all: index

# Uebersicht erstellen
# Ruft Script "genindex" auf und schreibt es in Datei 
index: md html
	@./genindex > $(INDEX_FILE)

# Wandelt alle sh-Dateien in md um
# zudem wird noch der pretext hinzugefuegt
md: $(MD_OBJECTS)
%.md: %.sh
	@./shelltomd < $< | sed '1 i $(PRE_TEXT)' > $@

# Wandelt alle Markdown-Dateien in HTML um
html: $(HTML_OBJECTS)
%.html: %.md
	@./Markdown.pl < $< > $@

# Entfernt alle von der Makefile erstellten Dateien
clean:
	@rm -f $(MD_OBJECTS)
	@rm -f $(HTML_OBJECTS)
	@rm -f $(INDEX_FILE)

# Gibt die Hilfe aus
help: ; @echo "$$showHelp"
