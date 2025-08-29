module NotionRubyRenderer
  module RailsHelper
    # Render Notion blocks with proper HTML escaping
    def render_notion_blocks(blocks, options = {})
      renderer = NotionRubyRenderer::Renderer.new(options)
      html = renderer.render(blocks)
      html.html_safe
    end
    
    # Include Notion renderer CSS in the view
    def notion_renderer_styles(inline: false)
      if inline
        NotionRubyRenderer::CssProvider.css_tag(inline: true).html_safe
      else
        stylesheet_link_tag('notion_renderer')
      end
    end
  end
end

# Include helper in ActionView if Rails is present
if defined?(Rails) && defined?(ActionView::Base)
  ActionView::Base.send :include, NotionRubyRenderer::RailsHelper
end