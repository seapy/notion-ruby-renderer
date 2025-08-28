module NotionRubyRenderer
  class CssProvider
    def self.default_css
      File.read(css_file_path)
    end

    def self.css_file_path
      File.expand_path("../../../assets/stylesheets/notion_renderer.css", __FILE__)
    end

    def self.css_tag(options = {})
      if options[:inline]
        "<style>\n#{default_css}\n</style>"
      else
        "<link rel=\"stylesheet\" href=\"#{options[:href] || '/assets/notion_renderer.css'}\">"
      end
    end
  end
end