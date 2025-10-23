.PHONY: deploy

SKILL_DIRS := $(shell find . -maxdepth 1 -type d -not -name '.' -not -name '.*' -exec basename {} \;)
TARGET_DIR := $(HOME)/.claude/skills

deploy:
	@echo "Deploying skills to $(TARGET_DIR)..."
	@for skill in $(SKILL_DIRS); do \
		echo "Processing $$skill..."; \
		mkdir -p "$(TARGET_DIR)/$$skill"; \
		for file in $$skill/*; do \
			if [ -f "$$file" ]; then \
				target="$(TARGET_DIR)/$$file"; \
				if [ -e "$$target" ] || [ -L "$$target" ]; then \
					rm "$$target"; \
				fi; \
				ln -s "$(CURDIR)/$$file" "$$target"; \
				echo "  Symlinked $$file -> $$target"; \
			fi; \
		done; \
	done
	@echo "Deployment complete!"
