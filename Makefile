.PHONY: deploy deploy-claude deploy-codex sync-skill-creator

SKILL_DIRS := $(shell find . -maxdepth 1 -type d -not -name '.' -not -name '.*' -not -name 'docs' -exec basename {} \;)
CLAUDE_TARGET := $(HOME)/.claude/skills
CLAUDE_AGENTS := $(HOME)/.claude/CLAUDE.md
CODEX_TARGET := $(HOME)/.codex/skills
CODEX_AGENTS := $(HOME)/.codex/AGENTS.md

define deploy_skills
	@echo "Deploying skills to $(1)..."
	@for skill in $(SKILL_DIRS); do \
		echo "Processing $$skill..."; \
		mkdir -p "$(1)/$$skill"; \
		find "$$skill" -type f | while read -r file; do \
			relative_path=$${file#$$skill/}; \
			target_file="$(1)/$$skill/$$relative_path"; \
			target_dir=$$(dirname "$$target_file"); \
			mkdir -p "$$target_dir"; \
			if [ -e "$$target_file" ] || [ -L "$$target_file" ]; then \
				rm "$$target_file"; \
			fi; \
			ln -s "$(CURDIR)/$$file" "$$target_file"; \
			echo "  Symlinked $$file -> $$target_file"; \
		done; \
	done
	@echo "Skill deployment complete!"
endef

define deploy_agents
	@echo "Deploying AGENTS.md to $(1)..."
	@if [ -e "$(1)" ] || [ -L "$(1)" ]; then \
		rm "$(1)"; \
	fi
	@ln -s "$(CURDIR)/AGENTS.md" "$(1)"
	@echo "  Symlinked AGENTS.md -> $(1)"
endef

deploy: deploy-claude deploy-codex
	@echo "Deployment complete!"

deploy-claude:
	$(call deploy_skills,$(CLAUDE_TARGET))
	$(call deploy_agents,$(CLAUDE_AGENTS))

deploy-codex:
	$(call deploy_skills,$(CODEX_TARGET))
	$(call deploy_agents,$(CODEX_AGENTS))

# Sync skill-creator from upstream anthropics/skills repo, overwriting local changes.
sync-skill-creator:
	@echo "Syncing skill-creator from anthropics/skills..."
	@rm -rf skill-creator
	@mkdir -p skill-creator
	@gh api repos/anthropics/skills/git/trees/main?recursive=1 --jq \
		'.tree[] | select(.path | startswith("skills/skill-creator/")) | select(.type == "blob") | .path' | \
		while read -r path; do \
			relative=$${path#skills/skill-creator/}; \
			mkdir -p "$$(dirname "skill-creator/$$relative")"; \
			curl -sL "https://raw.githubusercontent.com/anthropics/skills/main/$$path" \
				-o "skill-creator/$$relative"; \
			echo "  Downloaded $$relative"; \
		done
	@echo "skill-creator synced!"
