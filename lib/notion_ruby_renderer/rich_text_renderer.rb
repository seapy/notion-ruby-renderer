module NotionRubyRenderer
  class RichTextRenderer
    def initialize
      @color_mapper = ColorMapper.new
    end

    def render(rich_text_array)
      return "" unless rich_text_array

      rich_text_array.map do |rich_text|
        # Extract text content - support both formats
        text_content = if rich_text["plain_text"]
          rich_text["plain_text"]
        elsif rich_text["text"]
          rich_text["text"]["content"]
        else
          ""
        end
        
        text = escape_html(text_content)
        annotations = rich_text["annotations"]
        
        # Check for link in text object (Notion API format)
        href = rich_text["href"] || (rich_text["text"] && rich_text["text"]["link"] && rich_text["text"]["link"]["url"])

        if annotations
          css_classes = []
          
          if annotations["color"] && annotations["color"] != "default"
            # Replace underscores with hyphens for CSS class names
            color_class = annotations["color"].gsub("_", "-")
            css_classes << "notion-color-#{color_class}"
          end
          
          text = "<strong>#{text}</strong>" if annotations["bold"]
          text = "<em>#{text}</em>" if annotations["italic"]
          text = "<s>#{text}</s>" if annotations["strikethrough"]
          text = "<u>#{text}</u>" if annotations["underline"]
          
          if annotations["code"]
            text = "<code>#{text}</code>"
          elsif css_classes.any?
            text = "<span class=\"#{css_classes.join(' ')}\">#{text}</span>"
          end
        end

        if href
          text = "<a href=\"#{href}\">#{text}</a>"
        end

        text
      end.join
    end

    private

    def escape_html(text)
      return "" unless text
      text.gsub("&", "&amp;")
        .gsub("<", "&lt;")
        .gsub(">", "&gt;")
        .gsub('"', "&quot;")
        .gsub("'", "&#39;")
    end
  end
end