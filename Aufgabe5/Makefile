SHELL=/bin/dash
PRETEXT=\# Code Documentation
SH_OBJECTS=$(wildcard *.sh)
MD_OBJECTS=$(SH_OBJECTS:.sh=.md)

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

all: index.html

index: ; @echo "Index aufgerufen"

#führt die %.md regel solange aus, bis es zu allen .sh Datein eine .md datei gibt
md: $(MD_OBJECTS)
%.md: %.sh
	@$(SHELL) shelltomd < $< | sed '1 i $(PRETEXT)' >$@

help: ; @echo "$$showHelp"

clean:
	@rm -rf $(OBJHTML)
	@rm -rf $(MD_OBJECTS)
	@rm -rf index.html

# Make soll keine temp.-Dateien loeschen
# -> Ein .SECONDARY ohne Abhängigkeiten deaktiviert das automatische Löschen von Zwischenzielen
.SECONDARY:
