module NotionRubyRenderer
  class RichTextRenderer
    def initialize
      @color_mapper = ColorMapper.new
    end

    def render(rich_text_array)
      return "" unless rich_text_array

      rich_text_array.map do |rich_text|
        text = escape_html(rich_text["plain_text"])
        annotations = rich_text["annotations"]

        if annotations
          style_attrs = []
          
          if annotations["color"] && annotations["color"] != "default"
            color = annotations["color"]
            
            if color.end_with?("_background")
              bg_color = color.sub("_background", "")
              style_attrs << "background-color: #{@color_mapper.get_color(bg_color)}"
            else
              style_attrs << "color: #{@color_mapper.get_color(color)}"
            end
          end
          
          text = "<strong>#{text}</strong>" if annotations["bold"]
          text = "<em>#{text}</em>" if annotations["italic"]
          text = "<s>#{text}</s>" if annotations["strikethrough"]
          text = "<u>#{text}</u>" if annotations["underline"]
          
          if annotations["code"]
            code_styles = ["color: #EB5757"]
            style_attrs.each do |attr|
              code_styles << attr if attr.start_with?("background-color")
            end
            text = "<code style=\"#{code_styles.join('; ')}\">#{text}</code>"
          elsif style_attrs.any?
            text = "<span style=\"#{style_attrs.join('; ')}\">#{text}</span>"
          end
        end

        if rich_text["href"]
          text = "<a href=\"#{rich_text["href"]}\">#{text}</a>"
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