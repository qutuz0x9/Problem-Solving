# Included by the root Makefile. Holds the actual target logic.

.PHONY: new test lint index

new:
	@if [ -z "$(PLATFORM)" ] || [ -z "$(LANG)" ] || [ -z "$(NAME)" ]; then \
		echo "Usage: make new PLATFORM=<leetcode|codeforces|other> LANG=<go|python|javascript|typescript|cpp|rust> NAME=<slug> [NUM=<id>] [URL=<url>] [TITLE=<title>]"; \
		exit 1; \
	fi
	@helpers/new_problem.sh PLATFORM=$(PLATFORM) LANG=$(LANG) NAME=$(NAME) $(if $(NUM),NUM=$(NUM)) $(if $(URL),URL=$(URL)) $(if $(TITLE),TITLE=$(TITLE))

test:
	@helpers/run_tests.sh $(DIR)

lint:
	@helpers/run_lint.sh $(DIR)

index:
	@helpers/generate_index.sh
