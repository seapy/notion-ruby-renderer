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

      # Handle nested children blocks
      if block["has_children"] && block["children"]
        children_html = @renderer.render(block["children"], context)
        
        if type == "bulleted_list_item" || type == "numbered_list_item"
          html_content = html_content.gsub("</li>", "#{children_html}</li>")
        elsif html_content
          html_content = "#{html_content}\n#{children_html}"
        else
          html_content = children_html
        end
      end

      html_content
    end

    private

    def render_paragraph(block)
      content = @rich_text_renderer.render(block["paragraph"]["rich_text"])
      css_class = @renderer.css_classes[:paragraph]
      class_attr = css_class ? " class=\"#{css_class}\"" : ""
      "<p#{class_attr}>#{content}</p>"
    end

    def render_heading(block, level)
      content = @rich_text_renderer.render(block["heading_#{level}"]["rich_text"])
      css_class = @renderer.css_classes["h#{level}".to_sym]
      class_attr = css_class ? " class=\"#{css_class}\"" : ""
      "<h#{level}#{class_attr}>#{content}</h#{level}>"
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
      content = block["code"]["rich_text"].map { |rt| rt["plain_text"] }.join
      language = block["code"]["language"]
      
      code_class = language ? "language-#{language}" : ""
      code_class += " #{@renderer.css_classes[:code]}" if @renderer.css_classes[:code]
      code_class = code_class.strip
      
      class_attr = code_class.empty? ? "" : " class=\"#{code_class}\""
      
      pre_class = @renderer.css_classes[:pre]
      pre_attr = pre_class ? " class=\"#{pre_class}\"" : ""
      
      "<pre#{pre_attr}><code#{class_attr}>#{escape_html(content)}</code></pre>"
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
      
      title = fetch_page_title(url) || caption || "Link"
      
      css_class = @renderer.css_classes[:bookmark]
      class_attr = css_class ? " class=\"#{css_class}\"" : ""
      
      <<~HTML
        <div#{class_attr}>
          <a href="#{escape_html(url)}" target="_blank" rel="noopener noreferrer">
            <div class="bookmark-title">#{escape_html(title)}</div>
            <div class="bookmark-url">#{escape_html(url)}</div>
          </a>
        </div>
      HTML
      .strip
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
      
      css_class = @renderer.css_classes[:callout]
      class_attr = css_class ? " class=\"#{css_class}\"" : ""
      
      icon_html = if icon
        if icon["type"] == "emoji"
          "<span class=\"callout-icon\">#{icon["emoji"]}</span>"
        else
          ""
        end
      else
        ""
      end
      
      <<~HTML
        <div#{class_attr}>
          #{icon_html}
          <div class="callout-content">#{content}</div>
        </div>
      HTML
      .strip
    end

    def render_table(block)
      css_class = @renderer.css_classes[:table]
      class_attr = css_class ? " class=\"#{css_class}\"" : ""
      
      html = "<table#{class_attr}>"
      
      if block["has_children"] && block["children"]
        block["children"]["results"].each_with_index do |row, index|
          row_html = render_table_row(row)
          if index == 0 && block["table"]["has_row_header"]
            html += "<thead>#{row_html}</thead><tbody>"
          elsif index == 0
            html += "<tbody>#{row_html}"
          else
            html += row_html
          end
        end
        html += "</tbody>" if block["children"]["results"].any?
      end
      
      html += "</table>"
      html
    end

    def render_table_row(block)
      cells = block["table_row"]["cells"]
      html = "<tr>"
      
      cells.each do |cell|
        content = @rich_text_renderer.render(cell)
        html += "<td>#{content}</td>"
      end
      
      html += "</tr>"
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