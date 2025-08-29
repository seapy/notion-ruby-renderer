module NotionRubyRenderer
  class Engine < ::Rails::Engine
    isolate_namespace NotionRubyRenderer
    
    # Add assets to Rails asset pipeline
    initializer "notion_ruby_renderer.assets.precompile" do |app|
      app.config.assets.paths << root.join("assets", "stylesheets")
      app.config.assets.precompile += %w( notion_renderer.css )
    end
  end
end