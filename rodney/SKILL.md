---
name: rodney
description: Guide for automating Chrome browser interactions using the rodney CLI. This skill should be used when performing web automation tasks such as navigating to pages, taking screenshots, clicking elements, filling forms, extracting page content, or any other browser-based interaction.
---

# Rodney

Rodney is a command-line tool for Chrome automation. It provides headless browser control for navigating pages, interacting with elements, extracting content, and taking screenshots.

## Browser Lifecycle

Before any browser interaction, ensure Chrome is running:

```bash
rodney start
```

To check if the browser is already running:

```bash
rodney status
```

To shut down when done:

```bash
rodney stop
```

## Navigation

```bash
rodney open <url>          # Navigate to a URL
rodney back                # Go back in history
rodney forward             # Go forward in history
rodney reload              # Reload current page
rodney url                 # Print current URL
rodney title               # Print page title
```

## Extracting Page Content

To get page content for analysis:

```bash
rodney html                # Full page HTML
rodney html <selector>     # HTML of a specific element
rodney text <selector>     # Text content of an element
rodney attr <selector> <name>  # Attribute value of an element
```

To save a page as PDF:

```bash
rodney pdf [file]          # Save current page as PDF
```

## Interacting with Elements

```bash
rodney click <selector>           # Click an element
rodney input <selector> <text>    # Type text into an input field
rodney clear <selector>           # Clear an input field
rodney select <selector> <value>  # Select dropdown option by value
rodney submit <selector>          # Submit a form
rodney hover <selector>           # Hover over an element
rodney focus <selector>           # Focus an element
rodney file <selector> <path|->   # Set file on a file input (- for stdin)
rodney download <sel> [file|-]    # Download href/src target (- for stdout)
```

## JavaScript Evaluation

To run arbitrary JavaScript in the page context:

```bash
rodney js <expression>
```

## Waiting

To synchronize with page state before interacting:

```bash
rodney wait <selector>     # Wait for element to appear
rodney waitload            # Wait for page load
rodney waitstable          # Wait for DOM to stabilize
rodney waitidle            # Wait for network idle
rodney sleep <seconds>     # Sleep for N seconds
```

## Screenshots

```bash
rodney screenshot [-w N] [-h N] [file]  # Page screenshot (optional width/height)
rodney screenshot-el <selector> [file]  # Screenshot a specific element
```

## Tabs

```bash
rodney pages               # List all open pages/tabs
rodney page <index>        # Switch to page by index
rodney newpage [url]       # Open a new page/tab
rodney closepage [index]   # Close a page/tab
```

## Element Queries

To check element state without interaction:

```bash
rodney exists <selector>   # Check if element exists (exit 0 = yes, 1 = no)
rodney count <selector>    # Count matching elements
rodney visible <selector>  # Check if element is visible (exit 0/1)
```

## Accessibility Tree

To inspect the accessibility tree for understanding page structure:

```bash
rodney ax-tree [--depth N] [--json]              # Dump full accessibility tree
rodney ax-find [--name N] [--role R] [--json]    # Find accessible nodes
rodney ax-node <selector> [--json]               # Show accessibility info for element
```

The accessibility tree is useful for understanding page structure and finding elements when CSS selectors are unclear.

## Typical Workflow

A common automation sequence:

1. `rodney start` - launch the browser
2. `rodney open <url>` - navigate to the target page
3. `rodney waitload` or `rodney wait <selector>` - wait for page to be ready
4. Interact with the page (click, input, extract, screenshot, etc.)
5. `rodney stop` - shut down when done

When chaining multiple commands, use `&&` to ensure each step succeeds before proceeding. Insert `rodney wait`, `rodney waitload`, or `rodney sleep` between interactions when the page needs time to update.
