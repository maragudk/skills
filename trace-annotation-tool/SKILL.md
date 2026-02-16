---
name: trace-annotation-tool
description: Build a custom HTML/JS trace annotation tool for open coding during LLM error analysis. Use when the user wants to review LLM traces, annotate failures with free-form comments, and do first-pass qualitative labeling. Produces a single self-contained HTML file with vanilla JavaScript.
---

# Trace Annotation Tool Skill

Build lightweight, custom trace annotation interfaces for open coding during LLM error analysis. The tool loads traces from a JSON file and lets reviewers annotate each trace with free-form comments and a pass/fail/defer judgment. The output is a single self-contained HTML file with vanilla JS — no frameworks, no build steps.

## When to Use

- User wants to review LLM pipeline traces and annotate failures
- User is doing open coding / first-pass error analysis (not structured axial coding)
- User needs a simple tool to load traces and write free-form observations
- User wants something better than a spreadsheet but doesn't need a full platform

## Core Principles

These principles are drawn from grounded theory methodology and HCI research. Follow them closely.

### 1. Open Coding Focus

Open coding means reading traces and writing brief free-form notes about what you observe — where outputs are incorrect, surprising, or wrong. You do NOT start with a fixed taxonomy of errors. Let patterns emerge from the data.

Each trace gets:
- A **free-form annotation** field: the reviewer writes what they observe (e.g., "Missing pet-friendly constraint in SQL", "Tone too casual for investor client")
- An **optional pass/fail/defer** judgment: a binary holistic call. Even borderline cases should pick a side. Defer is for genuinely uncertain cases.
- That's it. No Likert scales. No structured tags. No checkboxes. Those come later in axial coding.

### 2. Examine the Entire Trace, Note the First Upstream Error

Traces can be complex with cascading failures. The tool must show the full trace (input, intermediate steps, tool calls, output) but the reviewer should focus on the **first (most upstream) failure**. Fixing the first error often resolves the whole chain.

### 3. HCI Principles for Review Interfaces

Apply these Nielsen/Norman design principles:

| Principle | Implementation |
|-----------|---------------|
| **Visibility of System Status** | Show current trace index, total count, how many annotated, progress bar |
| **User Control and Freedom** | Next/previous navigation, undo, ability to revisit any trace |
| **Consistency** | Same layout for every trace |
| **Recognition over Recall** | Show the trace content directly — don't make reviewers memorize anything |
| **Flexibility and Efficiency** | Keyboard shortcuts for power users |
| **Aesthetic and Minimalist Design** | Signal over noise. Emphasize the trace content, not the UI chrome |

### 4. Features That Matter

**Must have:**
- Keyboard shortcuts: `←`/`→` or `j`/`k` for navigation, `p` for pass, `f` for fail, `d` for defer, `Ctrl+Enter` to save annotation
- Visual hierarchy: clearly separate input, intermediate steps, and output. Use color, spacing, or collapsible sections
- Progressive disclosure: collapse intermediate trace steps by default, expand on click
- Progress indicator: "Trace 3 of 47 — 12 annotated"
- Defer button: prominent, for uncertain cases
- Auto-save: annotations persist without explicit save action (use localStorage)

**Nice to have (add if user requests):**
- Filtering by annotation status (all / annotated / unannotated / pass / fail / defer)
- Export annotations as JSON or CSV
- Search/find within traces
- Contextual metadata display (pipeline version, user segment, timestamps)
- Inline highlighting of problematic spans in the trace

**Avoid:**
- Likert scales (use binary pass/fail instead)
- Structured failure mode tags (that's axial coding, not open coding)
- Complex multi-panel layouts that overwhelm
- Generic spreadsheet-like views

## Trace Data Format

The tool expects a JSON file with an array of trace objects. The schema is intentionally flexible — traces can have any structure. The tool should handle these common patterns:

```json
[
  {
    "id": "trace-001",
    "input": "Find 3-bedroom homes under $600k near downtown that allow pets.",
    "steps": [
      {
        "type": "llm_call",
        "description": "Generate SQL query",
        "content": "SELECT * FROM listings WHERE bedrooms = 3 AND price < 600000..."
      },
      {
        "type": "tool_call",
        "description": "Execute SQL",
        "content": "Returned 2 listings (no pet filter applied)"
      },
      {
        "type": "llm_call",
        "description": "Draft email to client",
        "content": "Hi! Here are some great options..."
      }
    ],
    "output": "Email sent to client with 2 listings",
    "metadata": {
      "pipeline_version": "v2.3",
      "timestamp": "2025-01-15T10:30:00Z"
    }
  }
]
```

But also handle simpler formats like:
```json
[
  {
    "id": "1",
    "input": "What is the capital of France?",
    "output": "The capital of France is Lyon."
  }
]
```

The tool should gracefully render whatever fields are present. If `steps` exists, render them with progressive disclosure. If only `input`/`output` exist, show those.

## Building the Tool

### Step 1: Understand the User's Traces

Ask the user:
1. What does their trace data look like? (Ask for a sample or the JSON file)
2. What domain is this for? (Helps with visual hierarchy choices — e.g., if it's an email assistant, render the output as an email)
3. Any specific metadata they want visible?

If the user provides a JSON file, inspect it to understand the schema and adapt the template accordingly.

### Step 2: Build the HTML File

Create a single self-contained HTML file.

Key implementation details:

**File loading:** Use a file input (`<input type="file">`) to load the JSON traces. No server needed.

**State management:** Keep all state in a single JS object:
```javascript
const state = {
  traces: [],
  annotations: {},  // keyed by trace id: { comment: "", judgment: "pass"|"fail"|"defer"|null }
  currentIndex: 0,
  filter: "all"
};
```

**Persistence:** Save annotations to localStorage on every change. Load them back on startup. Also provide an export button.

**Rendering traces:** Render trace steps with collapsible sections. Use semantic HTML and clear visual hierarchy:
- Input: prominent, full width, distinct background
- Steps: collapsible, indented, with type labels (LLM call, tool call, retrieval, etc.)
- Output: prominent, full width, visually distinct from input
- Metadata: subtle, secondary — shown but not distracting

**Annotation area:** Below the trace display:
- Large textarea for free-form comment (this is the primary annotation — make it big)
- Three buttons: Pass (green), Fail (red), Defer (yellow/neutral)
- Show current judgment state clearly
- Auto-save on every keystroke (debounced)

**Navigation:**
- Previous / Next buttons
- Keyboard shortcuts
- Click-to-jump in the progress bar or trace list
- Filter dropdown to show all/annotated/unannotated/pass/fail/defer

### Step 3: Customize for the Domain

Based on the user's domain, make smart rendering choices:
- **Email assistant**: Render the output in an email-like card with proper formatting
- **Code generation**: Use a monospace font and syntax-highlighting-style background for code blocks
- **RAG/Q&A**: Show retrieved context in a distinct panel, clearly separated from the generated answer
- **Conversational agent**: Show the conversation as a chat-style thread
- **SQL/data pipeline**: Render SQL in monospace, show data results as a mini-table if possible

### Step 4: Polish

- Test keyboard shortcuts work and don't conflict with the textarea
- Ensure the progress indicator updates correctly
- Verify localStorage persistence works (load, save, export)
- Check that long traces don't break the layout (scrollable sections)
- Make sure the annotation textarea is focused by default for fast typing

## Design Guidelines

**Color palette:** Use a clean, neutral base with subtle accent colors for the judgment states:
- Pass: muted green (not neon)
- Fail: muted red/coral
- Defer: muted amber/gray
- Unannotated: no color / neutral

**Typography:** Use a clean monospace or sans-serif font appropriate for data review. System fonts are fine for a tool like this — readability over aesthetics.

**Layout:** Single column, vertically stacked. Trace on top, annotation below. Navigation at top or bottom. Don't use side panels unless the user specifically asks — they reduce the space available for trace content.

**Responsiveness:** The tool should work on a laptop screen (1280px+). Mobile support is not required.

## Anti-Patterns to Avoid

1. **Don't add structured failure mode tags** — this is open coding, not axial coding. The free-form comment IS the annotation.
2. **Don't use Likert scales** — binary pass/fail forces sharper thinking than vague 1-5 scores.
3. **Don't over-engineer** — a single HTML file is the goal. No React, no build steps, no dependencies.
4. **Don't default to a spreadsheet layout** — the whole point is that spreadsheets are bad for trace review.
5. **Don't hide the full trace** — intermediate steps should be accessible even if collapsed by default.
6. **Don't forget keyboard shortcuts** — speed of review directly correlates with engineering velocity.
7. **Don't make the annotation field small** — it's the most important part of the interface. Make it prominent.
