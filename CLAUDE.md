# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Build and Install
```bash
# Build the gem
gem build notion-ruby-renderer.gemspec

# Install locally built gem
gem install ./notion-ruby-renderer-*.gem

# Install dependencies
bundle install
```

### Console Access
```bash
# Open interactive Ruby console with gem loaded
bin/console

# Or use IRB directly
irb -r ./lib/notion_ruby_renderer
```

## Architecture Overview

This gem renders Notion API block objects to semantic HTML with customizable styling. The core components work together as follows:

### Core Components

1. **Renderer** (`lib/notion_ruby_renderer/renderer.rb`): Main entry point that orchestrates the rendering process. Handles list wrapping logic for consecutive list items and manages the overall block traversal.

2. **BlockRenderer** (`lib/notion_ruby_renderer/block_renderer.rb`): Handles individual Notion block types (paragraphs, headings, lists, code blocks, images, tables, etc.). Processes nested children blocks recursively.

3. **RichTextRenderer** (`lib/notion_ruby_renderer/rich_text_renderer.rb`): Processes Notion's rich text format including text formatting (bold, italic, underline, strikethrough), colors, and links.

4. **ImageHandler** (`lib/notion_ruby_renderer/image_handler.rb`): Extensible image processing system with two implementations:
   - `DefaultImageHandler`: Returns URLs unchanged
   - `CallbackImageHandler`: Allows custom image processing via callback blocks

5. **ColorMapper** (`lib/notion_ruby_renderer/color_mapper.rb`): Maps Notion color names to CSS classes for text and background colors.

6. **CssProvider** (`lib/notion_ruby_renderer/css_provider.rb`): Provides default CSS styles for rendered HTML elements.

### Key Design Patterns

- **Dependency Injection**: The Renderer accepts an image handler and CSS classes configuration, allowing customization without modifying core code.
- **Recursive Rendering**: Blocks with children are rendered recursively, maintaining proper HTML nesting.
- **List Aggregation**: Consecutive list items are automatically wrapped in appropriate `<ul>` or `<ol>` tags.
- **Context Passing**: Optional context parameter flows through the rendering pipeline for custom data handling.

## Supported Notion Block Types

The gem currently handles: paragraph, heading_1-3, bulleted/numbered list items, quote, code, divider, image, bookmark, toggle, callout, table, and table_row blocks.