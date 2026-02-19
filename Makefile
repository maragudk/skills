.PHONY: deploy

deploy:
	@if [ -e "$(HOME)/.claude/CLAUDE.md" ] || [ -L "$(HOME)/.claude/CLAUDE.md" ]; then \
		rm "$(HOME)/.claude/CLAUDE.md"; \
	fi
	@ln -s "$(CURDIR)/AGENTS.md" "$(HOME)/.claude/CLAUDE.md"
	@echo "Symlinked AGENTS.md -> $(HOME)/.claude/CLAUDE.md"
