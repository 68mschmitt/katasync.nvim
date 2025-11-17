# Example Templates

This directory contains example templates that you can use with katasync.nvim.

## Usage

1. Copy these template files to your configured `templates_dir` (default: `~/notes/templates`)
2. The filename (without `.md` extension) becomes the template key
3. Use the template picker when creating or sorting notes

## Available Examples

- **meeting.md** - Meeting notes with attendees, agenda, and action items
- **daily.md** - Daily journal template with reflections and planning
- **project.md** - Project planning template with goals and milestones
- **review.md** - Review/retrospective template for analyzing past work

## Creating Your Own Templates

Simply create a `.md` file in your `templates_dir`. The content can include these variables:

- `{{title}}` - Note label (or "Note" if not provided)
- `{{date}}` - Current date (YYYY-MM-DD)
- `{{datetime}}` - Full timestamp (YYYY-MM-DD HH:MM:SS)
- `{{timestamp}}` - Filename timestamp
- `{{content}}` - Original buffer content (only in SortNote)

## Configuration

```lua
require("katasync").setup({
  base_dir = "~/notes",
  templates_dir = "~/notes/templates",  -- where template files live
  create_templates_dir = true,          -- auto-create directory

  -- You can still define templates in config (these take precedence)
  templates = {
    quick = "{{title}}\n\n",
  },
})
```

## Tips

- Keep templates organized in the templates directory
- Use meaningful filenames (the filename becomes the template name)
- Template variables are optional - use plain text if you prefer
- Config-based templates override file-based templates with the same name
- The "none" template is always available (empty template)
