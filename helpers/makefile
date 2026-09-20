# Included by the root Makefile. Holds the actual target logic.

.PHONY: new test lint bench index

# Shell-quote a value (single quotes, with embedded ' escaped) so titles and
# URLs containing spaces, &, ?, etc. reach the script as one argument.
shq = '$(subst ','\'',$(1))'

new:
	@if [ -z "$(PLATFORM)" ] || [ -z "$(LANG)" ] || [ -z "$(NAME)" ]; then \
		echo "Usage: make new PLATFORM=<leetcode|codeforces|codewars|other> LANG=<go|python|javascript|typescript|cpp|rust> NAME=<slug> [NUM=<id>] [URL=<url>] [TITLE=<title>]"; \
		exit 1; \
	fi
	@helpers/new_problem.sh PLATFORM=$(call shq,$(PLATFORM)) LANG=$(call shq,$(LANG)) NAME=$(call shq,$(NAME)) $(if $(NUM),NUM=$(call shq,$(NUM))) $(if $(URL),URL=$(call shq,$(URL))) $(if $(TITLE),TITLE=$(call shq,$(TITLE)))

test:
	@helpers/run_tests.sh $(DIR)

lint:
	@helpers/run_lint.sh $(DIR)

bench:
	@helpers/run_bench.sh $(DIR)

index:
	@helpers/generate_index.sh
