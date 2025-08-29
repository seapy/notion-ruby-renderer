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
      html_parts = []
      list_items = []
      current_list_type = nil

      # Handle both array of blocks and Notion API response format
      blocks_array = blocks.is_a?(Hash) && blocks["results"] ? blocks["results"] : blocks
      blocks_array = [blocks_array] unless blocks_array.is_a?(Array)

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

          html_parts << block_renderer.render(block, context)
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
  end
end