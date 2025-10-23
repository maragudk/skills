# Project Decisions

This document records significant architectural and design decisions made throughout the project's development.

## 2025-10-23: Decision log skill design

Created a decision-log skill to record significant architectural decisions in `docs/decisions.md`. Key design choices:

**Format:** Simple dated entries (`## YYYY-MM-DD: Title` + description) rather than structured ADR templates. Easier to scan and write while capturing essential information.

**Chronological order:** Append new entries to bottom (oldest first) to create a natural timeline showing project evolution.

**Detail level:** Flexible based on complexity - brief summaries for simple decisions, detailed context/alternatives/tradeoffs for complex architectural choices.

**Proactive behavior:** Conservative - only suggest recording clearly significant architectural decisions (databases, frameworks, core patterns), not minor implementation details. Reduces noise while remaining useful.

**Structure:** No categories, tags, or cross-references. Keep it simple with chronological format and descriptive titles. Additional structure can be added later if needed.

**Initialization:** Auto-create `docs/decisions.md` with explanatory header when it doesn't exist for easy adoption.
