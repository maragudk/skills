---
name: marimo
description: Guide for creating and working with marimo notebooks, the reactive Python notebook that stores as pure .py files. This skill should be used when creating, editing, running, or deploying marimo notebooks.
license: MIT
---

# marimo

## Overview

marimo is an open-source reactive Python notebook that reinvents notebooks as reproducible, interactive, and shareable Python programs. Unlike traditional Jupyter notebooks, marimo notebooks:

- Store as pure `.py` files (Git-friendly, no JSON)
- Execute reactively (like a spreadsheet)
- Run as scripts or deploy as web apps
- Prevent bugs through automatic dependency tracking

## When to Use This Skill

Use this skill when:
- Creating or editing marimo notebooks
- Running notebooks as apps or scripts
- Converting Jupyter notebooks to marimo
- Working with interactive UI elements in Python
- Deploying Python notebooks as web applications

## Installation

```bash
# Basic installation
pip install marimo

# With recommended extras (SQL, plotting, etc.)
pip install marimo[recommended]

# With SQL support
pip install marimo[sql]
```

Start the introductory tutorial:

```bash
marimo tutorial intro
```

## CLI Commands

### Create and Edit Notebooks

```bash
marimo edit                      # Create new notebook
marimo edit notebook.py          # Edit existing notebook
marimo edit --port 8080          # Custom port
marimo edit --headless           # No browser auto-open
marimo edit --watch              # Auto-reload on file changes
marimo edit --sandbox            # Isolate dependencies per notebook
```

### Run as Web App

```bash
marimo run notebook.py           # Run as read-only app
marimo run notebook.py --port 8080
marimo run notebook.py --include-code  # Show source code
marimo run notebook.py --watch         # Auto-reload on file changes
marimo run notebook.py --sandbox       # Isolate dependencies per notebook
```

### Run as Script

```bash
python notebook.py               # Execute directly as Python
```

### Create from AI Prompt

```bash
marimo new "analyze sales data"  # Generate notebook from prompt
marimo new prompt.txt            # Use prompt from file
```

### Convert from Other Formats

```bash
marimo convert notebook.ipynb -o notebook.py  # From Jupyter
marimo convert document.md -o notebook.py     # From Markdown
marimo convert script.py -o notebook.py       # From Python script
```

### Export to Other Formats

```bash
marimo export html notebook.py -o output.html     # Static HTML
marimo export html-wasm notebook.py -o output.html  # Browser-executable
marimo export ipynb notebook.py -o output.ipynb   # Jupyter notebook
marimo export md notebook.py -o output.md         # Markdown
marimo export script notebook.py -o script.py     # Flat Python script
```

### Utilities

```bash
marimo check notebook.py         # Validate and lint
marimo check --fix notebook.py   # Auto-fix issues
marimo env                       # Show environment info
marimo recover notebook.json     # Recover from JSON backup
```

## Key Concepts

### Reactivity

marimo notebooks are reactive: running a cell automatically runs all cells that depend on it. The execution order is determined by variable dependencies (DAG), not cell position.

```python
# Cell 1
x = 10

# Cell 2 - automatically re-runs when x changes
y = x * 2

# Cell 3 - automatically re-runs when y changes
print(f"Result: {y}")
```

### Cell Rules

1. **One definition per variable**: Each global variable must be defined in exactly one cell
2. **No mutation tracking**: Mutations like `list.append()` aren't tracked; reassign instead
3. **Declare and mutate together**: If mutating is needed, do it in the same cell as the declaration

### File Format

Notebooks are pure Python files with marimo decorators:

```python
import marimo

__generated_with = "0.10.0"
app = marimo.App()

@app.cell
def _():
    import marimo as mo
    return (mo,)

@app.cell
def _(mo):
    mo.md("# My Notebook")
    return ()

@app.cell
def _():
    x = 42
    return (x,)

if __name__ == "__main__":
    app.run()
```

## Core API

### Markdown

```python
import marimo as mo

mo.md("# Heading")
mo.md(f"Value is **{x}**")  # Interpolation supported
```

### UI Elements

All UI elements are in `mo.ui`:

```python
# Sliders and numbers
slider = mo.ui.slider(0, 100, value=50, label="Value")
number = mo.ui.number(0, 100, value=50)

# Text inputs
text = mo.ui.text(placeholder="Enter name")
textarea = mo.ui.text_area(rows=5)

# Selection
dropdown = mo.ui.dropdown(["A", "B", "C"], value="A")
radio = mo.ui.radio(["Option 1", "Option 2"])
checkbox = mo.ui.checkbox(label="Enable feature")
multiselect = mo.ui.multiselect(["A", "B", "C"])

# Dates
date = mo.ui.date(label="Select date")
date_range = mo.ui.date_range()

# Files
file = mo.ui.file(filetypes=[".csv", ".json"])
file_browser = mo.ui.file_browser(initial_path="./data")

# Tables and data
table = mo.ui.table(dataframe)
dataframe_ui = mo.ui.dataframe(df)  # No-code transformations
data_explorer = mo.ui.data_explorer(df)

# Buttons
button = mo.ui.button(label="Click me")
run_button = mo.ui.run_button(label="Run")
refresh = mo.ui.refresh(interval=5)

# Advanced
code_editor = mo.ui.code_editor(language="python")
chat = mo.ui.chat(model)
```

Access values with `.value`:

```python
slider = mo.ui.slider(0, 100)
# In another cell:
result = slider.value * 2
```

### Layouts

```python
# Horizontal/vertical stacks
mo.hstack([element1, element2])
mo.vstack([element1, element2])

# Tabs
mo.ui.tabs({"Tab 1": content1, "Tab 2": content2})

# Accordion
mo.accordion({"Section 1": content1, "Section 2": content2})

# Callouts
mo.callout("Important note", kind="info")  # info, warn, danger, success

# Sidebar
mo.sidebar([element1, element2])
```

### SQL

SQL cells integrate with the reactive system:

```python
# Query a dataframe directly
result = mo.sql(f"SELECT * FROM {df} WHERE value > {threshold.value}")

# With database connection
mo.sql(f"SELECT * FROM users LIMIT 10", engine=connection)
```

Supported databases: PostgreSQL, MySQL, SQLite, DuckDB, Snowflake, BigQuery.

### State Management

For advanced use cases (rarely needed):

```python
get_count, set_count = mo.state(0)

# In another cell
button = mo.ui.button(label="Increment", on_change=lambda _: set_count(get_count() + 1))

# In another cell
mo.md(f"Count: {get_count()}")
```

### Control Flow

```python
# Stop cell execution conditionally
mo.stop(not data_loaded, mo.md("Loading data..."))

# The rest of the cell only runs if data_loaded is True
process(data)
```

### Caching

```python
@mo.cache
def expensive_computation(x):
    # Result cached based on input
    return heavy_processing(x)

# Disk-based caching
@mo.persistent_cache
def very_expensive(x):
    return process(x)
```

### Media

```python
# Images
mo.image(src="path/to/image.png", alt="Description")
mo.image(src=bytes_data)  # From bytes

# Audio and video
mo.audio(src="audio.mp3")
mo.video(src="video.mp4")

# PDF display
mo.pdf(src="document.pdf")

# Download link
mo.download(data=bytes_or_file, filename="export.csv")

# Plain text (preserves whitespace)
mo.plain_text("Preformatted text")
```

### Diagrams

```python
# Mermaid diagrams
mo.mermaid("""
graph TD
    A[Start] --> B[Process]
    B --> C[End]
""")

# Statistic cards
mo.stat(value="$1,234", label="Revenue", direction="increase")
```

### Status and Progress

```python
# Progress bar
with mo.status.progress_bar(total=100) as bar:
    for i in range(100):
        bar.update()

# Spinner
with mo.status.spinner("Loading..."):
    do_work()
```

### Query Parameters and CLI Args

```python
# Access URL query parameters (in app mode)
params = mo.query_params()
filter_value = params.get("filter", "default")

# Set query parameters
mo.query_params.set({"filter": "active"})

# Access CLI arguments (when run as script)
args = mo.cli_args()
```

### HTML Manipulation

```python
# Create HTML elements
element = mo.Html("<div>Custom HTML</div>")

# Batch multiple elements
mo.Html.batch([element1, element2])

# Apply CSS styles
element.style({"color": "red", "font-size": "16px"})
```

### Watch (File System)

```python
# React to file changes
file_content = mo.watch("config.json")
# Cell re-runs when file changes
```

## Running as Apps

### Layout Options

1. **Vertical (default)**: Outputs stacked vertically, code hidden
2. **Grid**: Drag-and-drop arrangement via editor
3. **Slides**: Slideshow presentation mode

Configure in the editor's layout settings. Layout metadata saves to a `layouts/` folder.

### Deployment

```bash
# Local web app
marimo run notebook.py

# Export static HTML
marimo export html notebook.py -o app.html

# Browser-executable (WASM)
marimo export html-wasm notebook.py -o app.html
```

For production deployments, use Docker, Kubernetes, or cloud platforms. The `marimo run` command can be containerized with standard Python Docker images.

## WASM Notebooks

marimo notebooks can run entirely in the browser using WebAssembly:

- No server required
- Deploy as static HTML files
- Works on GitHub Pages
- 2GB memory limit
- Most pure Python packages supported (NumPy, pandas, scikit-learn, matplotlib, DuckDB, Polars)

```bash
marimo export html-wasm notebook.py -o index.html
```

## Best Practices

### Code Organization

- Minimize global variables; use functions to encapsulate logic
- Prefix intermediate variables with underscore (`_temp`)
- Extract complex logic into separate Python modules
- Organize freely—cell position doesn't affect execution order

### Reactivity

- Declare and mutate variables in the same cell
- Create new objects instead of mutating existing ones across cells
- Avoid `on_change` handlers; let reactivity handle updates
- Use `mo.stop()` to prevent expensive computations until ready

### Performance

- Use lazy runtime mode for expensive computations (via notebook settings)
- Leverage `@mo.cache` for expensive pure functions
- Use native DuckDB output for large SQL queries
- Disable cells temporarily while iterating

### Idempotent Cells

Structure cells so identical inputs produce identical outputs:

```python
# Good: Pure function
def process(data):
    return data.copy().assign(new_col=lambda d: d.value * 2)

result = process(df)

# Avoid: In-place mutation
df["new_col"] = df["value"] * 2  # Mutation not tracked
```

## Interactive Charts

marimo integrates with plotting libraries for interactive selections:

```python
import altair as alt

chart = mo.ui.altair_chart(
    alt.Chart(df).mark_point().encode(x="x", y="y")
)

# In another cell - selection is reactive
selected_data = chart.value
```

Supported: Altair, Plotly, matplotlib (via mpl interactions).

## Resources

- [Documentation](https://docs.marimo.io/)
- [GitHub Repository](https://github.com/marimo-team/marimo)
- [Examples Gallery](https://marimo.io/gallery)
- [Discord Community](https://discord.gg/JE7nhX6mD8)
