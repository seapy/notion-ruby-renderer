require_relative "notion_ruby_renderer/version"
require_relative "notion_ruby_renderer/renderer"
require_relative "notion_ruby_renderer/block_renderer"
require_relative "notion_ruby_renderer/rich_text_renderer"
require_relative "notion_ruby_renderer/image_handler"
require_relative "notion_ruby_renderer/color_mapper"
require_relative "notion_ruby_renderer/css_provider"

# Load Rails Engine if Rails is defined
if defined?(Rails)
  require_relative "notion_ruby_renderer/engine"
end

module NotionRubyRenderer
  class Error < StandardError; end
end