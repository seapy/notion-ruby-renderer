module NotionRubyRenderer
  class BlockRenderer
    def initialize(renderer)
      @renderer = renderer
      @rich_text_renderer = renderer.rich_text_renderer
    end

    def render(block, context = nil)
      type = block["type"]

      html_content = case type
      when "paragraph"
        render_paragraph(block)
      when "heading_1"
        render_heading(block, 1)
      when "heading_2"
        render_heading(block, 2)
      when "heading_3"
        render_heading(block, 3)
      when "bulleted_list_item"
        render_list_item(block)
      when "numbered_list_item"
        render_list_item(block)
      when "quote"
        render_quote(block)
      when "code"
        render_code(block)
      when "divider"
        render_divider
      when "image"
        render_image(block, context)
      when "bookmark"
        render_bookmark(block)
      when "toggle"
        render_toggle(block, context)
      when "callout"
        render_callout(block)
      when "table"
        render_table(block)
      when "table_row"
        render_table_row(block)
      else
        nil
      end

      # Handle nested children blocks (except for toggle and table which handle their own children)
      if block["has_children"] && block["children"] && type != "toggle" && type != "table"
        if type == "bulleted_list_item" || type == "numbered_list_item"
          # For list items, render children without the wrapping newlines
          children_html = render_nested_list(block["children"], context)
          html_content = html_content.gsub("</li>", "#{children_html}</li>")
        else
          children_html = @renderer.render(block["children"], context)
          if html_content
            html_content = "#{html_content}\n#{children_html}"
          else
            html_content = children_html
          end
        end
      end

      html_content
    end

    private

    def render_nested_list(children, context)
      # Handle both API response format and direct array format
      children_array = children.is_a?(Hash) && children["results"] ? children["results"] : children
      
      # Group list items by type for nested lists
      if children_array.all? { |c| c["type"] == "bulleted_list_item" }
        items = children_array.map { |c| render(c, context) }
        "<ul>#{items.join}</ul>"
      elsif children_array.all? { |c| c["type"] == "numbered_list_item" }
        items = children_array.map { |c| render(c, context) }
        "<ol>#{items.join}</ol>"
      else
        @renderer.render(children, context)
      end
    end

    def render_paragraph(block)
      content = @rich_text_renderer.render(block["paragraph"]["rich_text"])
      color = block["paragraph"]["color"]
      
      css_classes = []
      css_classes << @renderer.css_classes[:paragraph] if @renderer.css_classes[:paragraph]
      css_classes << "notion-color-#{color.gsub('_', '-')}" if color && color != "default"
      
      class_attr = css_classes.any? ? " class=\"#{css_classes.join(' ')}\"" : ""
      "<p#{class_attr}>#{content}</p>"
    end

    def render_heading(block, level)
      heading_data = block["heading_#{level}"]
      content = @rich_text_renderer.render(heading_data["rich_text"])
      css_class = @renderer.css_classes["h#{level}".to_sym]
      class_attr = css_class ? " class=\"#{css_class}\"" : ""
      heading_html = "<h#{level}#{class_attr}>#{content}</h#{level}>"
      
      if heading_data["is_toggleable"]
        "<details><summary>#{heading_html}</summary></details>"
      else
        heading_html
      end
    end

    def render_list_item(block)
      type = block["type"]
      key = type == "bulleted_list_item" ? "bulleted_list_item" : "numbered_list_item"
      content = @rich_text_renderer.render(block[key]["rich_text"])
      css_class = @renderer.css_classes[:list_item]
      class_attr = css_class ? " class=\"#{css_class}\"" : ""
      "<li#{class_attr}>#{content}</li>"
    end

    def render_quote(block)
      content = @rich_text_renderer.render(block["quote"]["rich_text"])
      css_class = @renderer.css_classes[:blockquote]
      class_attr = css_class ? " class=\"#{css_class}\"" : ""
      "<blockquote#{class_attr}>#{content}</blockquote>"
    end

    def render_code(block)
      # Extract text content - support both formats
      content = block["code"]["rich_text"].map do |rt|
        if rt["plain_text"]
          rt["plain_text"]
        elsif rt["text"]
          rt["text"]["content"]
        else
          ""
        end
      end.join
      language = block["code"]["language"]
      
      code_class = language ? "language-#{language}" : ""
      code_class += " #{@renderer.css_classes[:code]}" if @renderer.css_classes[:code]
      code_class = code_class.strip
      
      class_attr = code_class.empty? ? "" : " class=\"#{code_class}\""
      
      # Use notion-code as default pre class
      pre_class = @renderer.css_classes[:pre] || "notion-code"
      pre_attr = " class=\"#{pre_class}\""
      
      "<pre#{pre_attr}><code#{class_attr}>#{content}</code></pre>"
    end

    def render_divider
      css_class = @renderer.css_classes[:hr]
      class_attr = css_class ? " class=\"#{css_class}\"" : ""
      "<hr#{class_attr}>"
    end

    def render_image(block, context)
      original_url = block["image"]["file"]&.dig("url") || block["image"]["external"]&.dig("url")
      caption = @rich_text_renderer.render(block["image"]["caption"])
      
      url = @renderer.image_handler.handle(original_url, context)
      
      img_class = @renderer.css_classes[:img]
      img_attr = img_class ? " class=\"#{img_class}\"" : ""
      
      html = "<img src=\"#{url}\" alt=\"#{escape_html(caption)}\"#{img_attr}>"
      
      if caption.empty?
        html
      else
        figure_class = @renderer.css_classes[:figure]
        figure_attr = figure_class ? " class=\"#{figure_class}\"" : ""
        caption_class = @renderer.css_classes[:figcaption]
        caption_attr = caption_class ? " class=\"#{caption_class}\"" : ""
        
        "<figure#{figure_attr}>#{html}<figcaption#{caption_attr}>#{caption}</figcaption></figure>"
      end
    end

    def render_bookmark(block)
      url = block["bookmark"]["url"]
      caption = @rich_text_renderer.render(block["bookmark"]["caption"])
      
      "<div class=\"notion-bookmark\"><a href=\"#{escape_html(url)}\">#{escape_html(url)}</a><p>#{caption}</p></div>"
    end

    def render_toggle(block, context)
      summary = @rich_text_renderer.render(block["toggle"]["rich_text"])
      css_class = @renderer.css_classes[:details]
      class_attr = css_class ? " class=\"#{css_class}\"" : ""
      
      html = "<details#{class_attr}><summary>#{summary}</summary>"
      
      if block["has_children"] && block["children"]
        children_html = @renderer.render(block["children"], context)
        html += children_html
      end
      
      html += "</details>"
      html
    end

    def render_callout(block)
      content = @rich_text_renderer.render(block["callout"]["rich_text"])
      icon = block["callout"]["icon"]
      color = block["callout"]["color"]
      
      css_classes = ["notion-callout"]
      css_classes << "notion-color-#{color.gsub('_', '-')}" if color && color != "default"
      
      class_attr = " class=\"#{css_classes.join(' ')}\""
      
      icon_html = if icon && icon["type"] == "emoji"
        "<span class=\"notion-callout-icon\">#{icon["emoji"]}</span>"
      else
        ""
      end
      
      "<div#{class_attr}>#{icon_html}<div class=\"notion-callout-content\">#{content}</div></div>"
    end

    def render_table(block)
      css_class = @renderer.css_classes[:table]
      class_attr = css_class ? " class=\"#{css_class}\"" : ""
      
      html = "<table#{class_attr}>\n"
      
      if block["has_children"] && block["children"]
        # Handle both API response format and direct array format
        children = block["children"].is_a?(Hash) && block["children"]["results"] ? block["children"]["results"] : block["children"]
        
        children.each_with_index do |row, index|
          is_header = index == 0 && block["table"]["has_column_header"]
          row_html = render_table_row(row, is_header)
          if is_header
            html += "<thead>\n#{row_html}</thead>\n<tbody>\n"
          elsif index == 0
            html += "<tbody>\n#{row_html}"
          else
            html += row_html
          end
        end
        html += "</tbody>\n" if children.any?
      end
      
      html += "</table>"
      html
    end

    def render_table_row(block, is_header = false)
      cells = block["table_row"]["cells"]
      html = "<tr>"
      tag = is_header ? "th" : "td"
      
      cells.each do |cell|
        content = @rich_text_renderer.render(cell)
        html += "<#{tag}>#{content}</#{tag}>"
      end
      
      html += "</tr>\n"
      html
    end

    def fetch_page_title(url)
      return nil unless url
      
      begin
        require "net/http"
        require "uri"
        
        uri = URI.parse(url)
        return nil unless uri.scheme && uri.host
        
        3.times do
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = (uri.scheme == "https")
          http.open_timeout = 5
          http.read_timeout = 5
          
          path = uri.path.empty? ? "/" : uri.path
          path += "?#{uri.query}" if uri.query
          
          request = Net::HTTP::Get.new(path)
          request["User-Agent"] = "Mozilla/5.0 (compatible; NotionRenderer/1.0)"
          request["Accept"] = "text/html"
          
          response = http.request(request)
          
          case response.code
          when "200"
            if match = response.body.match(/<title[^>]*>([^<]+)<\/title>/i)
              title = match[1].strip
              title = title.gsub("&amp;", "&")
                .gsub("&lt;", "<")
                .gsub("&gt;", ">")
                .gsub("&quot;", '"')
                .gsub("&#39;", "'")
                .gsub("&#x27;", "'")
                .gsub("&nbsp;", " ")
              return title
            end
            break
          when "301", "302", "303", "307", "308"
            location = response["location"]
            break unless location
            
            if location.start_with?("/")
              uri = URI.parse("#{uri.scheme}://#{uri.host}#{location}")
            else
              uri = URI.parse(location)
            end
          else
            break
          end
        end
      rescue => e
        nil
      end
      
      nil
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