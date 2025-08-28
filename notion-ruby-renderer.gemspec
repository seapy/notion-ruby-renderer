# frozen_string_literal: true

require_relative "lib/notion_ruby_renderer/version"

Gem::Specification.new do |spec|
  spec.name = "notion-ruby-renderer"
  spec.version = NotionRubyRenderer::VERSION
  spec.authors = ["seapy"]
  spec.email = ["seapy@example.com"]

  spec.summary = "A Ruby gem for rendering Notion blocks to HTML"
  spec.description = "Convert Notion API block objects to semantic HTML with customizable styling and image handling"
  spec.homepage = "https://github.com/seapy/notion-ruby-renderer"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir.glob("{lib,assets}/**/*") + %w[README.md Rakefile]
  spec.require_paths = ["lib"]

  # Dependencies
  spec.add_development_dependency "rake", "~> 13.0"
end