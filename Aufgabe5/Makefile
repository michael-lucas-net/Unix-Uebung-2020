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
PRETEXT = \# Code Documentation
INDEX_FILE = index.html                   # so wird die Verzeichnis-Datei heißen

SH_OBJECTS = $(wildcard *.sh)             # Alle sh-Dateien
MD_OBJECTS_FOL = $(wildcard *.md)         # Alle md-Dateien aus dem Ordner
MD_OBJECTS_CONV = $(SH_OBJECTS:.sh=.md)   # Alle konvertierten md-Dateien
MD_OBJECTS = $(MD_OBJECTS_FOL) $(MD_OBJECTS_CONV) # Alle md-Dateien
HTML_OBJECTS = $(MD_OBJECTS:.md=.html)    # Alle html-Dateien

CLEAN_OBJECTS = $(INDEX_FILE)             # Verzeichnis-Datei loeschen
CLEAN_OBJECTS += $(HTML_OBJECTS)          # Kovnerrtierte HTML-Dateien loeschen
CLEAN_OBJECTS += $(MD_OBJECTS_CONV)       # konvertierte MD-Dateien loeschen

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

# Um zu verhindern, dass er z.B: "clean" nicht ausfuehrt,
# wenn es eine Datei gibt, die "clean" heißt.
.PHONY: all index md html clean help 

# Ruft standardmaessig index auf
all: index

# Uebersicht erstellen
# Ruft Script "genindex" auf und schreibt es in Datei 
index: md html
	@./genindex > $(INDEX_FILE)

# Wandelt alle sh-Dateien in md um
# zudem wird noch der pretext in der ersten Zeile hinzugefuegt
md: $(MD_OBJECTS)
%.md: %.sh
	@./shelltomd < $< | sed "1i $(PRETEXT)" > $@

# Wandelt alle Markdown-Dateien in HTML um
html: $(HTML_OBJECTS)
%.html: %.md
	@./Markdown.pl < $< > $@

# Entfernt alle von der Makefile erstellten Dateien
clean:
	@rm -f $(CLEAN_OBJECTS)

# Gibt die Hilfe aus
help: ; @echo "$$showHelp"
