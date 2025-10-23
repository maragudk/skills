---
name: nanobanana
description: Guide for generating and editing images using generative AI with the nanobanana CLI
license: MIT
---

# Nanobanana

This is a guide for generating and editing images using the nanobanana CLI tool.

Nanobanana is a command-line interface for the Nano Banana image generation API, which uses Google's generative AI models.

## Prerequisites

The `GOOGLE_API_KEY` environment variable must be set, or a `.env` file with the key must be present in the working directory.

## Generating images

To generate a single image:

```bash
nanobanana generate output.png "a beautiful sunset over mountains"
```

The output can be either a `.png` or `.jpg` file.

## Generating multiple variations

To generate multiple variations of an image:

```bash
nanobanana generate -count 3 output.png "abstract art with vibrant colors"
```

When generating multiple images, the output filename will be modified to include a number suffix (e.g., `output-1.png`, `output-2.png`, `output-3.png`).

## Editing existing images

To edit or modify an existing image using a text prompt:

```bash
nanobanana generate -i input.png output.png "make the sky purple and add stars"
```

This is useful for making specific changes to existing images based on natural language instructions.

## Tips for effective prompts

- Be specific and descriptive about what you want in the image
- Include details about style, colors, mood, composition, and subject matter
- For edits, clearly describe what should change while the rest remains the same
- You can reference art styles, artists, or specific visual aesthetics

## Examples

Generate a logo:
```bash
nanobanana generate logo.png "minimalist tech company logo with geometric shapes in blue and white"
```

Create concept art:
```bash
nanobanana generate concept.png "futuristic city skyline at night with neon lights and flying vehicles, cyberpunk style"
```

Edit an existing photo:
```bash
nanobanana generate -i photo.png enhanced.png "enhance the colors and make it look like golden hour"
```

Generate multiple options:
```bash
nanobanana generate -count 5 icon.png "simple icon of a banana, flat design, yellow and white"
```
