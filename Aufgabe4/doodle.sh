cat tests/cache/kalender.html \
	| sed -n "/<tr>/,/<\/tr>/p" \
	| sed -n '6~7p' \
	| grep "[AB][1-9] (" \
	| grep -o "<div class=\"date\">.*<\/div>" \
	| sed "s/<div class=\"date\">//g; s/<\/div>//g;" \
	| sed "s/.*/|- &/g" \
	> test.html