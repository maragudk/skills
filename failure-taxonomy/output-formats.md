# Output Formats Reference

This document defines the schemas for the three artifacts produced by the failure taxonomy skill.

## 1. Taxonomy Definition

Produce this as a Markdown document (or JSON if the user prefers machine-readable output).

### Markdown Format

```markdown
# Failure Mode Taxonomy: [Application Name]

Generated from [N] open-coded trace annotations.

## 1. [Failure Mode Title]

**Definition:** [One sentence describing what qualifies as this failure.]

**Examples from annotations:**
- "[Representative annotation 1]"
- "[Representative annotation 2]"
- "[Representative annotation 3]"

**What this looks like in a trace:** [Brief description of how this failure
manifests in the pipeline — which step fails, what the symptom is.]

**Engineering signal:** [What a developer would investigate or fix.]

## 2. [Next Failure Mode]
...
```

### JSON Format

```json
{
  "application": "Description of the application being evaluated",
  "total_annotations_analyzed": 45,
  "taxonomy_version": 1,
  "failure_modes": [
    {
      "id": "fm_01",
      "title": "Short Descriptive Title",
      "definition": "One sentence defining when this failure mode applies.",
      "examples": [
        "Representative annotation text 1",
        "Representative annotation text 2"
      ],
      "trace_manifestation": "How this shows up in the pipeline.",
      "engineering_signal": "What to investigate or fix."
    }
  ],
  "uncategorized": [
    {
      "annotation_index": 12,
      "annotation": "Original text that didn't fit any category",
      "notes": "Why it didn't fit and whether it warrants a new category"
    }
  ]
}
```

## 2. Re-labeled Dataset

Augment the original annotations with binary columns for each failure mode.

### CSV Format

```
trace_id,annotation,fm_01_constraint_violation,fm_02_persona_mismatch,fm_03_hallucinated_data
t001,"Missing pet-friendly filter in SQL",1,0,0
t002,"Used investor jargon with first-time buyer",0,1,0
t003,"Claimed property has solar panels (it doesn't)",0,0,1
t004,"Proposed showing on unavailable day",1,0,0
```

### JSON Format

```json
[
  {
    "trace_id": "t001",
    "annotation": "Missing pet-friendly filter in SQL",
    "failure_modes": {
      "fm_01_constraint_violation": 1,
      "fm_02_persona_mismatch": 0,
      "fm_03_hallucinated_data": 0
    }
  }
]
```

**Rules for re-labeling:**
- Every trace gets a value for every failure mode — no blanks.
- A trace CAN have multiple failure modes marked as 1.
- If the annotation says the trace passed (no failure), all failure modes are 0.
- If an annotation doesn't clearly match any failure mode, mark all as 0 and add the
  trace to an "uncategorized" list for the user to review manually.

## 3. Summary Statistics

### Markdown Table

```markdown
# Failure Mode Prevalence

| Rank | Failure Mode | Count | Rate | Cumulative |
|------|-------------|-------|------|------------|
| 1    | Constraint Violation | 12 | 26.7% | 26.7% |
| 2    | Persona Mismatch | 8 | 17.8% | 44.4% |
| 3    | Hallucinated Data | 6 | 13.3% | 57.8% |

- Total traces analyzed: 45
- Traces with at least one failure: 32 (71.1%)
- Traces with multiple failures: 5 (11.1%)
- Uncategorized annotations: 3 (6.7%)
```

### JSON Format

```json
{
  "total_traces": 45,
  "traces_with_failures": 32,
  "traces_with_multiple_failures": 5,
  "uncategorized_count": 3,
  "failure_modes": [
    {
      "id": "fm_01",
      "title": "Constraint Violation",
      "count": 12,
      "rate": 0.267,
      "rank": 1
    }
  ]
}
```

## File Naming Conventions

When saving outputs to files:

- Taxonomy: `taxonomy_v{N}.md` or `taxonomy_v{N}.json`
- Re-labeled data: `traces_labeled.csv` or `traces_labeled.json`
- Summary: `failure_summary.md` or `failure_summary.json`

Version the taxonomy file (`v1`, `v2`, ...) since iteration is expected. The re-labeled
data and summary should correspond to the latest taxonomy version.
