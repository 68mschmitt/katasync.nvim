# katasync.nvim

A minimal Neovim plugin for quick note creation and organization. Capture thoughts instantly in your inbox, then sort them into a structured hierarchy when ready.

## Features

### Quick Note Creation (`:NewNote`)
- **Single Command**: `:NewNote` creates a blank markdown file instantly
- **Unique Filenames**: Timestamped format `YYYY-MM-DD_HH-MM-SS--note.md`
- **Auto-open**: Immediately opens the new file for editing
- **Collision Handling**: Automatically handles filename conflicts

### Direct Note Creation (`:CreateNote`)
- **Create in Place**: Create notes directly in their final destination
- **Recent Destinations**: Quick access to recently used directories with saved templates
- **Directory Drill-down**: Interactive navigation to choose location
- **Optional Labeling**: Add descriptive names or skip for timestamp-only filenames
- **Template Selection**: Choose from multiple templates with variable substitution
- **Template Variables**: Support for `{{title}}`, `{{date}}`, `{{datetime}}`, `{{timestamp}}`
- **Smart Naming**: Format becomes `{label}-{timestamp}--note.md` (or just `{timestamp}--note.md` if no label)

### Inbox Display (`:ListInbox`)
- **Visual Inbox**: Display all unsorted notes in your inbox
- **Relative Timestamps**: See how old each note is ("2 hours ago", "yesterday", etc.)
- **Interactive Picker**: Select notes to open and review
- **Sorting Options**: View notes newest-first or oldest-first
- **Empty Inbox Detection**: Helpful message when inbox is empty
- **Quick Access**: Streamline the capture-then-sort workflow

### Note Sorting (`:SortNote`)
- **Recent Destinations**: Quick access to recently used directories with saved templates
- **Directory Drill-down**: Interactive navigation through your note structure
- **Optional Labeling**: Add descriptive names or skip for timestamp-only filenames
- **Template Application**: Apply templates when sorting with original content preservation
- **Template Variables**: Support for `{{title}}`, `{{date}}`, `{{datetime}}`, `{{timestamp}}`, and `{{content}}`
- **Smart Content Handling**: Template content merged with original buffer content
- **Timestamp Preservation**: Keeps original creation timestamp
- **Smart Renaming**: Format becomes `{label}-{timestamp}--note.md` (or just `{timestamp}--note.md` if no label)
- **True Move**: Original file is moved, not copied
- **Cross-filesystem Support**: Works across different filesystems

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "68mschmitt/katasync.nvim",
  cmd = { "NewNote", "CreateNote", "SortNote", "ListInbox" },
  keys = {
    { "<leader>nn", "<cmd>NewNote<cr>", desc = "New note (inbox)" },
    { "<leader>nc", "<cmd>CreateNote<cr>", desc = "Create note at location" },
    { "<leader>ns", "<cmd>SortNote<cr>", desc = "Sort/move note" },
    { "<leader>ni", "<cmd>ListInbox<cr>", desc = "List inbox notes" },
  },
  opts = {
    inbox_dir = "~/notes/inbox",
    base_dir = "~/notes",
  },
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  '68mschmitt/katasync.nvim',
  config = function()
    require('katasync').setup({
      inbox_dir = '~/notes/inbox',
    })
  end
}
```

## Configuration

```lua
require("katasync").setup({
  -- Note Creation
  inbox_dir = "~/notes/inbox",              -- Directory for new notes
  base_dir = "~/notes",                      -- Base directory for CreateNote and sorting
  file_ext = ".md",                          -- File extension
  timestamp_fmt = "%Y-%m-%d_%H-%M-%S",      -- Timestamp format
  open_after_create = true,                  -- Open file after creating
  auto_save_new_note = true,                 -- Auto-save new notes to disk (false = manual :w)
  notify = true,                             -- Show notifications

  -- Template Directory (optional)
  templates_dir = nil,                       -- Directory for template files (default: {base_dir}/templates)
  create_templates_dir = false,              -- Auto-create templates directory if missing

  -- Templates for CreateNote and SortNote
  templates = {
    none = "",
    default = "# {{title}}\n\nCreated: {{date}}\n\n",
    meeting = [[# Meeting: {{title}}

Date: {{date}}

## Attendees
- 

## Agenda
1. 

## Discussion Notes


## Action Items
- [ ] 

## Next Meeting
]],
    journal = [[# Daily Journal - {{date}}

## Morning Thoughts


## What Happened Today


## Grateful For
1. 
2. 
3. 

## Tomorrow's Focus
]],
    task = [[# Task: {{title}}

Created: {{datetime}}

## Status
- [ ] Not Started

## Description


## Steps
1. 

## Notes
]],
    archive = [[# Archived: {{title}}

Date: {{date}}
Original content:

{{content}}
]],
  },
  default_template = "none",                 -- Pre-selected template in picker
  
  -- Recent Destinations (for CreateNote and SortNote)
  enable_recent_dirs = true,                 -- Enable recent destinations feature
  max_recent_dirs = 5,                       -- Number of recent destinations to remember
  recent_state_file = vim.fn.stdpath("state") .. "/katasync-mru.json",
  
  -- Note Sorting
  trailing_marker = "--note",                -- Filename suffix marker
  exclude_dirs = { ".git", ".obsidian" },   -- Directories to exclude from picker
  confirm_on_cross_fs = false,               -- Confirm cross-filesystem moves
  allow_non_md = true,                       -- Allow sorting non-markdown files
})
```

### Auto-Save Behavior

- **`auto_save_new_note = true`** (default): File is immediately saved to disk when created. The file exists in your filesystem before you start editing.
- **`auto_save_new_note = false`**: File is only created in a buffer. You must save with `:w` to persist it. Closing the buffer without saving leaves no empty file behind.

## Usage

### Commands

- `:NewNote` - Creates a blank markdown file in your inbox
- `:CreateNote` - Create a note directly in a chosen location with optional label and template
- `:ListInbox` - Display all inbox notes with relative timestamps for easy review
  - `:ListInbox newest` - Sort by newest first (default)
  - `:ListInbox oldest` - Sort by oldest first
- `:SortNote` - Move and rename the current note with interactive directory selection

### Workflows

#### Capture-Then-Sort (Unknown destination)
1. **Capture**: Use `:NewNote` to quickly create a note in your inbox
2. **Edit**: Write your content without worrying about organization
3. **Review**: Use `:ListInbox` to see all unsorted notes with relative timestamps
   - Select a note to open and review
   - See at a glance which notes need attention
4. **Sort**: When ready, use `:SortNote` to:
   - **Quick path**: Select from recent destinations (includes saved template)
   - **Full path**: Navigate through your directory structure
   - Choose a destination (or create new directories)
   - Optionally provide a descriptive label (or press Enter to skip)
   - Select a template from your configured options (skipped if using recent)
   - Original content is preserved and merged with template
   - File is automatically moved, renamed, and template applied

#### Create-In-Place (Known destination)
1. **Create**: Use `:CreateNote` to create a note directly:
   - **Quick path**: Select from recent destinations (includes saved template)
   - **Full path**: Navigate through your directory structure
   - Choose a destination (or create new directories)
   - Optionally provide a descriptive label (or press Enter to skip)
   - Select a template from your configured options (skipped if using recent)
   - File is created with the selected template (variables substituted)
2. **Edit**: Write your content in the final location

**Recent Destinations**: The plugin remembers your last 5 used directory + template combinations for both `:CreateNote` and `:SortNote`. Select a recent entry to skip both directory and template pickers, going straight to the label prompt.

### Programmatic API

```lua
local katasync = require("katasync")

-- Create a new note in inbox and get the path
local path = katasync.new_note()

-- Create a note in chosen location (interactive)
katasync.create_note_at()

-- Display inbox notes (interactive)
katasync.list_inbox()

-- Sort the current note
katasync.sort_note()
```

## File Naming

### New Notes (`:NewNote`)
- `2025-10-08_09-17-33--note.md` - Inbox format
- `2025-10-08_09-17-33--note--2.md` - With collision handling

### Created Notes (`:CreateNote`)
- `miata-boost-2025-10-14_13-42-10--note.md` - With label
- `2025-10-14_13-42-10--note.md` - Without label (skipped)
- `{label}-{timestamp}--note.md` - General pattern with label
- `{timestamp}--note.md` - General pattern without label
- Created directly in final destination
- Collision handling with `--2`, `--3`, etc.

### Sorted Notes (`:SortNote`)
- `miata-boost-2025-10-08_11-07-15--note.md` - With label
- `2025-10-08_11-07-15--note.md` - Without label (skipped)
- `{label}-{timestamp}--note.md` - General pattern with label
- `{timestamp}--note.md` - General pattern without label
- Timestamp is preserved from original file
- Label precedes timestamp for readability (when provided)
- Collision handling with `--2`, `--3`, etc.

## Templates

Templates can be defined in two ways:

1. **In Configuration** - Define templates directly in your Lua config (as shown above)
2. **In Files** - Create individual `.md` files in your templates directory

### Template Directory

You can organize templates as individual markdown files in a dedicated directory:

**Configuration:**

```lua
require("katasync").setup({
  base_dir = "~/notes",
  templates_dir = "~/notes/templates",  -- defaults to {base_dir}/templates
  create_templates_dir = true,          -- auto-create if missing

  -- You can still define templates in config
  templates = {
    quick = "{{title}}\n\n{{content}}",  -- Config templates override file templates
  },
})
```

**File-Based Templates:**

Create `.md` files in your `templates_dir`. The filename (without extension) becomes the template key.

Example: `~/notes/templates/meeting.md`
```markdown
# Meeting: {{title}}

Date: {{date}}
Attendees:
-

Notes:
{{content}}
```

This creates a template with key `meeting` that appears in the template picker.

**Template Precedence:**

1. **Config-based templates** (highest priority)
2. **File-based templates**
3. **Built-in templates** (e.g., "none")

If you define a template named `meeting` in both your config and as `meeting.md`, the config version will be used.

**Benefits of File-Based Templates:**

- Keep your config file clean and minimal
- Easier to edit templates without restarting Neovim
- Version control templates separately from config
- Share templates across machines or team members
- Better organization for many templates

### Template Variables

Templates support variable substitution with the following placeholders:

**Available in both `:CreateNote` and `:SortNote`:**
- `{{title}}` - Replaced with the note label (or "Note" if no label provided)
- `{{date}}` - Today's date in `YYYY-MM-DD` format
- `{{datetime}}` - Full timestamp in `YYYY-MM-DD HH:MM:SS` format
- `{{timestamp}}` - Filename timestamp in configured format

**Available only in `:SortNote`:**
- `{{content}}` - Original buffer contents before sorting

### Template Content Handling (`:SortNote`)

When sorting a note with a template:

1. **Template contains `{{content}}`**: Original content is inserted where the variable appears
   ```lua
   template = "# Archived\n\n{{content}}"
   -- Result: Template header + original content at position
   ```

2. **Template does NOT contain `{{content}}`**: Original content is appended to the end
   ```lua
   template = "# New Header\n\n"
   -- Result: Template content + original content appended
   ```

### Example Template Configuration

```lua
templates = {
  none = "",
  default = "# {{title}}\n\nCreated: {{date}}\n\n",
  meeting = [[# Meeting: {{title}}

Date: {{date}}

## Attendees
- 

## Agenda
]],
  -- Template with {{content}} for sorting
  archive = [[# Archived: {{title}}

Date: {{date}}
Original content:

{{content}}
]],
}
```

## Recent Destinations

The plugin tracks your most recently used directory + template combinations when using `:CreateNote` and `:SortNote`. When you invoke these commands, you'll see:

```
Select destination:
→ projects/miata [task] (2 hours ago)
→ journal [journal] (today)
─────────────
📁 Browse directories...
```

**Benefits:**
- Skip directory navigation for frequent destinations
- Automatically use the same template as last time
- Faster workflow: 3 clicks → 1 click + label input
- Shared history between `:CreateNote` and `:SortNote` for consistent workflows

**Storage:** Recent destinations are stored locally in `~/.local/state/nvim/katasync-mru.json`

## Directory Navigation

When browsing directories, you'll see:
- **← Go Back** - Navigate to parent directory (hidden at base)
- **✓ Drop Here** - Select current directory as destination
- **+ Create New** - Create a new subdirectory
- **[Subdirectories]** - Existing subdirectories (alphabetical)

## Philosophy

**Two workflows for different needs**

- **Capture fast, organize later**: `:NewNote` → `:SortNote`
  - Zero friction capture to inbox
  - Thoughtful organization when ready
- **Create in place**: `:CreateNote`
  - Direct creation when destination is known
  - Recent destinations for lightning-fast repeated workflows
  - Optional template support for structured notes
- Timestamp preservation maintains creation history
- Clean, predictable file naming for easy searching

## License

MIT
