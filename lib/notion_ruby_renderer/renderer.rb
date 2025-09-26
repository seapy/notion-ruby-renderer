module NotionRubyRenderer
  class Renderer
    attr_reader :image_handler, :css_classes, :block_renderer, :rich_text_renderer

    def initialize(options = {})
      @image_handler = options[:image_handler] || DefaultImageHandler.new
      @css_classes = options[:css_classes] || {}
      @rich_text_renderer = RichTextRenderer.new
      @block_renderer = BlockRenderer.new(self)
    end

    def render(blocks, context = nil, wrapper: true)
      # Handle both array of blocks and Notion API response format
      blocks_array = blocks.is_a?(Hash) && blocks["results"] ? blocks["results"] : blocks
      blocks_array = [blocks_array] unless blocks_array.is_a?(Array)

      # First pass: collect headings
      headings = collect_headings(blocks_array)

      # Second pass: render blocks
      html_parts = []
      list_items = []
      current_list_type = nil

      blocks_array.each do |block|
        type = block["type"]

        if type == "bulleted_list_item" || type == "numbered_list_item"
          list_type = type == "bulleted_list_item" ? "ul" : "ol"

          if current_list_type && current_list_type != list_type
            html_parts << wrap_list_items(list_items, current_list_type)
            list_items = []
          end

          current_list_type = list_type
          list_items << block_renderer.render(block, context)
        else
          if current_list_type && list_items.any?
            html_parts << wrap_list_items(list_items, current_list_type)
            list_items = []
            current_list_type = nil
          end

          rendered = block_renderer.render(block, context)

          # Replace table_of_contents placeholder with actual TOC
          if type == "table_of_contents" && rendered
            rendered = generate_table_of_contents(rendered, headings)
          end

          html_parts << rendered
        end
      end

      if current_list_type && list_items.any?
        html_parts << wrap_list_items(list_items, current_list_type)
      end

      content = html_parts.compact.join("\n")

      # Wrap with notion-ruby-renderer class by default
      wrapper ? "<div class=\"notion-ruby-renderer\">#{content}</div>" : content
    end

    def render_block(block, context = nil)
      block_renderer.render(block, context)
    end

    private

    def wrap_list_items(items, list_type)
      css_class = css_classes[list_type.to_sym]
      class_attr = css_class ? " class=\"#{css_class}\"" : ""
      "<#{list_type}#{class_attr}>\n#{items.join("\n")}\n</#{list_type}>"
    end

    def collect_headings(blocks_array, collected = [], parent_blocks = [])
      blocks_array.each do |block|
        type = block["type"]

        if type =~ /^heading_[123]$/
          level = type.match(/heading_(\d)/)[1].to_i
          heading_data = block["heading_#{level}"]
          plain_text = heading_data["rich_text"].map { |rt| rt["plain_text"] || rt.dig("text", "content") || "" }.join
          heading_id = generate_heading_id(plain_text)

          collected << {
            level: level,
            text: plain_text,
            id: heading_id
          }
        end

        # Recursively collect headings from children
        if block["has_children"] && block["children"]
          children = block["children"].is_a?(Hash) && block["children"]["results"] ? block["children"]["results"] : block["children"]
          collect_headings(children, collected, parent_blocks + [block])
        end
      end

      collected
    end

    def generate_heading_id(text)
      # Convert heading text to a URL-safe ID (same as in BlockRenderer)
      text.downcase
          .gsub(/[^\w\s-]/, '') # Remove non-word characters
          .gsub(/\s+/, '-')     # Replace spaces with hyphens
          .gsub(/-+/, '-')      # Replace multiple hyphens with single
          .gsub(/^-|-$/, '')    # Remove leading/trailing hyphens
    end

    def generate_table_of_contents(placeholder_html, headings)
      return placeholder_html if headings.empty?

      # Extract attributes from placeholder
      match = placeholder_html.match(/<div([^>]*).*?<\/div>/)
      return placeholder_html unless match

      attributes = match[1]

      # Build TOC HTML - use recursive approach for clarity
      toc_html = "<div#{attributes}>"
      toc_html += "<nav aria-label=\"Table of contents\">"
      toc_html += build_toc_list(headings, 1)
      toc_html += "</nav>"
      toc_html += "</div>"

      toc_html
    end

    def build_toc_list(headings, min_level)
      return "" if headings.empty?

      html = "<ul class=\"notion-table-of-contents-list\">"
      i = 0

      while i < headings.length
        heading = headings[i]
        level = heading[:level]

        # Skip headings that are too deep for this recursion level
        if level < min_level
          i += 1
          next
        end

        # Start a new list item
        html += "<li class=\"notion-table-of-contents-item notion-table-of-contents-item-level-#{level}\">"
        html += "<a href=\"##{heading[:id]}\">#{escape_html(heading[:text])}</a>"

        # Collect children (deeper level headings)
        children = []
        j = i + 1
        while j < headings.length
          next_level = headings[j][:level]
          break if next_level <= level  # Stop when we reach same or shallower level
          children << headings[j]
          j += 1
        end

        # Recursively build nested list if there are children
        if children.any?
          nested_html = build_toc_list(children, level + 1)
          html += nested_html
        end

        html += "</li>"

        # Skip the children we just processed
        i = j > i ? j : i + 1
      end

      html += "</ul>"
      html
    end

    def escape_html(text)
      return "" unless text
      text.to_s.gsub("&", "&amp;")
        .gsub("<", "&lt;")
        .gsub(">", "&gt;")
        .gsub('"', "&quot;")
        .gsub("'", "&#39;")
    end
  end
end