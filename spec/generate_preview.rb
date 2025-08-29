#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/setup"
require "notion_ruby_renderer"
require_relative "fixtures/notion_blocks"

def generate_preview_html
  renderer = NotionRubyRenderer::Renderer.new
  
  html_sections = []
  
  NotionTestFixtures::BLOCKS.each do |block_type, variants|
    next if block_type == :combined_list
    
    variants.each do |variant_name, block_data|
      section_title = "#{block_type.to_s.tr('_', ' ').capitalize} - #{variant_name}"
      rendered_html = renderer.render_block(block_data)
      
      html_sections << <<~HTML
        <div class="test-section">
          <h3 class="test-title">#{section_title}</h3>
          <div class="test-input">
            <h4>Input (Notion Block):</h4>
            <pre><code>#{block_data.to_s.gsub('<', '&lt;').gsub('>', '&gt;')}</code></pre>
          </div>
          <div class="test-output">
            <h4>Output (Rendered HTML):</h4>
            <div class="rendered-content">
              #{rendered_html}
            </div>
          </div>
          <div class="test-html-source">
            <h4>HTML Source:</h4>
            <pre><code>#{rendered_html.gsub('<', '&lt;').gsub('>', '&gt;')}</code></pre>
          </div>
        </div>
      HTML
    end
  end
  
  # Add combined list test
  combined_blocks = NotionTestFixtures.get_block(:combined_list, :blocks)
  combined_html = renderer.render(combined_blocks)
  html_sections << <<~HTML
    <div class="test-section">
      <h3 class="test-title">Combined Lists (List Wrapping Test)</h3>
      <div class="test-input">
        <h4>Input (Multiple List Items):</h4>
        <pre><code>#{combined_blocks.to_s.gsub('<', '&lt;').gsub('>', '&gt;')}</code></pre>
      </div>
      <div class="test-output">
        <h4>Output (Wrapped Lists):</h4>
        <div class="rendered-content">
          #{combined_html}
        </div>
      </div>
      <div class="test-html-source">
        <h4>HTML Source:</h4>
        <pre><code>#{combined_html.gsub('<', '&lt;').gsub('>', '&gt;')}</code></pre>
      </div>
    </div>
  HTML
  
  # Generate complete HTML document
  <<~HTML
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Notion Ruby Renderer - Visual Test Preview</title>
      <style>
        /* Base styles */
        body {
          font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
          line-height: 1.6;
          color: #333;
          max-width: 1200px;
          margin: 0 auto;
          padding: 20px;
          background: #f5f5f5;
        }
        
        h1 {
          color: #2c3e50;
          border-bottom: 3px solid #3498db;
          padding-bottom: 10px;
          margin-bottom: 30px;
        }
        
        .test-section {
          background: white;
          border-radius: 8px;
          padding: 20px;
          margin-bottom: 30px;
          box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        
        .test-title {
          color: #2c3e50;
          margin-top: 0;
          font-size: 1.3em;
          border-bottom: 2px solid #ecf0f1;
          padding-bottom: 10px;
        }
        
        .test-input, .test-output, .test-html-source {
          margin: 15px 0;
        }
        
        .test-input h4, .test-output h4, .test-html-source h4 {
          color: #7f8c8d;
          margin-bottom: 10px;
          font-size: 0.9em;
          text-transform: uppercase;
          letter-spacing: 1px;
        }
        
        .test-input pre, .test-html-source pre {
          background: #f8f9fa;
          border: 1px solid #dee2e6;
          border-radius: 4px;
          padding: 15px;
          overflow-x: auto;
          font-size: 12px;
          line-height: 1.4;
        }
        
        .test-input code, .test-html-source code {
          font-family: 'Monaco', 'Menlo', 'Ubuntu Mono', monospace;
        }
        
        .rendered-content {
          background: #fff;
          border: 2px solid #e1e8ed;
          border-radius: 4px;
          padding: 20px;
          min-height: 50px;
        }
        
        /* Notion styles from the gem */
        #{NotionRubyRenderer::CssProvider.default_css rescue ""}
        
        /* Additional styles for better visibility */
        .notion-callout {
          margin: 10px 0;
        }
        
        .notion-bookmark {
          border: 1px solid #e1e8ed;
          padding: 10px;
          border-radius: 4px;
          margin: 10px 0;
        }
        
        table {
          margin: 10px 0;
        }
        
        blockquote {
          margin: 10px 0;
        }
        
        details {
          margin: 10px 0;
        }
        
        .timestamp {
          color: #7f8c8d;
          font-size: 0.9em;
          margin-top: 30px;
          text-align: center;
          padding: 20px;
          border-top: 1px solid #ecf0f1;
        }
      </style>
    </head>
    <body>
      <h1>🎨 Notion Ruby Renderer - Visual Test Preview</h1>
      <p>This page shows the rendering output for various Notion block types. Each section displays the input block data, the rendered HTML output, and the HTML source code.</p>
      
      #{html_sections.join("\n")}
      
      <div class="timestamp">
        Generated on: #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}
      </div>
    </body>
    </html>
  HTML
end

# Generate and save the preview HTML
output_path = File.join(__dir__, 'preview.html')
File.write(output_path, generate_preview_html)

puts "✅ Preview HTML generated successfully!"
puts "📁 File saved to: #{output_path}"
puts "🌐 Open in browser: file://#{File.expand_path(output_path)}"