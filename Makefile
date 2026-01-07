.PHONY: deploy

SKILL_DIRS := $(shell find . -maxdepth 1 -type d -not -name '.' -not -name '.*' -not -name 'docs' -exec basename {} \;)
TARGET_DIR := $(HOME)/.claude/skills

deploy:
	@echo "Deploying skills to $(TARGET_DIR)..."
	@for skill in $(SKILL_DIRS); do \
		echo "Processing $$skill..."; \
		mkdir -p "$(TARGET_DIR)/$$skill"; \
		find "$$skill" -type f | while read -r file; do \
			relative_path=$${file#$$skill/}; \
			target_file="$(TARGET_DIR)/$$skill/$$relative_path"; \
			target_dir=$$(dirname "$$target_file"); \
			mkdir -p "$$target_dir"; \
			if [ -e "$$target_file" ] || [ -L "$$target_file" ]; then \
				rm "$$target_file"; \
			fi; \
			ln -s "$(CURDIR)/$$file" "$$target_file"; \
			echo "  Symlinked $$file -> $$target_file"; \
		done; \
	done
	@echo "Deploying AGENTS.md to $(HOME)/.claude/CLAUDE.md..."
	@if [ -e "$(HOME)/.claude/CLAUDE.md" ] || [ -L "$(HOME)/.claude/CLAUDE.md" ]; then \
		rm "$(HOME)/.claude/CLAUDE.md"; \
	fi
	@ln -s "$(CURDIR)/AGENTS.md" "$(HOME)/.claude/CLAUDE.md"
	@echo "  Symlinked AGENTS.md -> $(HOME)/.claude/CLAUDE.md"
	@echo "Deployment complete!"
