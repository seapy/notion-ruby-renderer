# frozen_string_literal: true

require "spec_helper"
require_relative "../fixtures/notion_blocks"

RSpec.describe NotionRubyRenderer::Renderer do
  let(:renderer) { described_class.new }

  describe "paragraph rendering" do
    it "renders simple paragraph" do
      block = NotionTestFixtures.get_block(:paragraph, :simple)
      result = renderer.render_block(block)
      expect(result).to eq('<p>This is a simple paragraph.</p>')
    end

    it "renders formatted paragraph" do
      block = NotionTestFixtures.get_block(:paragraph, :formatted)
      result = renderer.render_block(block)
      expect(result).to eq('<p>This is <strong>bold</strong>, <em>italic</em>, <u>underline</u>, and <s>strikethrough</s> text.</p>')
    end

    it "renders paragraph with link" do
      block = NotionTestFixtures.get_block(:paragraph, :with_link)
      result = renderer.render_block(block)
      expect(result).to eq('<p>Visit <a href="https://openai.com">OpenAI</a> for more info.</p>')
    end

    it "renders colored paragraph" do
      block = NotionTestFixtures.get_block(:paragraph, :colored)
      result = renderer.render_block(block)
      expect(result).to eq('<p class="notion-color-gray-background"><span class="notion-color-red">Red text</span> and <span class="notion-color-blue-background">blue background</span></p>')
    end
  end

  describe "heading rendering" do
    it "renders heading 1" do
      block = NotionTestFixtures.get_block(:heading_1, :simple)
      result = renderer.render_block(block)
      expect(result).to eq('<h1>Heading Level 1</h1>')
    end

    it "renders toggleable heading 1" do
      block = NotionTestFixtures.get_block(:heading_1, :with_toggle)
      result = renderer.render_block(block)
      expect(result).to eq('<details><summary><h1>Toggleable Heading 1</h1></summary></details>')
    end

    it "renders heading 2" do
      block = NotionTestFixtures.get_block(:heading_2, :simple)
      result = renderer.render_block(block)
      expect(result).to eq('<h2>Heading Level 2</h2>')
    end

    it "renders heading 3" do
      block = NotionTestFixtures.get_block(:heading_3, :simple)
      result = renderer.render_block(block)
      expect(result).to eq('<h3>Heading Level 3</h3>')
    end
  end

  describe "list rendering" do
    it "renders simple bulleted list item" do
      block = NotionTestFixtures.get_block(:bulleted_list_item, :simple)
      result = renderer.render_block(block)
      expect(result).to eq('<li>First bullet point</li>')
    end

    it "renders nested bulleted list" do
      block = NotionTestFixtures.get_block(:bulleted_list_item, :nested)
      result = renderer.render_block(block)
      expect(result).to eq('<li>Parent bullet<ul><li>Nested bullet 1</li><li>Nested bullet 2</li></ul></li>')
    end

    it "renders simple numbered list item" do
      block = NotionTestFixtures.get_block(:numbered_list_item, :simple)
      result = renderer.render_block(block)
      expect(result).to eq('<li>First numbered item</li>')
    end

    it "renders nested numbered list" do
      block = NotionTestFixtures.get_block(:numbered_list_item, :nested)
      result = renderer.render_block(block)
      expect(result).to eq('<li>Parent numbered item<ol><li>Nested numbered 1</li></ol></li>')
    end

    it "wraps consecutive list items" do
      blocks = NotionTestFixtures.get_block(:combined_list, :blocks)
      result = renderer.render(blocks, nil, wrapper: false)
      expected = <<~HTML.strip
        <ul>
        <li>Bullet 1</li>
        <li>Bullet 2</li>
        </ul>
        <ol>
        <li>Number 1</li>
        <li>Number 2</li>
        </ol>
      HTML
      expect(result).to eq(expected)
    end
    
    it "includes wrapper div by default" do
      blocks = NotionTestFixtures.get_block(:combined_list, :blocks)
      result = renderer.render(blocks)
      expect(result).to include('<div class="notion-ruby-renderer">')
      expect(result).to include('</div>')
    end
  end

  describe "quote rendering" do
    it "renders quote block" do
      block = NotionTestFixtures.get_block(:quote, :simple)
      result = renderer.render_block(block)
      expect(result).to eq('<blockquote>This is a quote block.</blockquote>')
    end

    it "renders quote block with inline code" do
      block = NotionTestFixtures.get_block(:quote, :with_inline_code)
      result = renderer.render_block(block)
      expect(result).to eq('<blockquote>Use <code>console.log()</code> to debug your JavaScript code.</blockquote>')
    end
  end

  describe "code rendering" do
    it "renders code block with language" do
      block = NotionTestFixtures.get_block(:code, :simple)
      result = renderer.render_block(block)
      expected = <<~HTML.strip
        <pre class="notion-code"><code class="language-ruby">def hello_world
          puts &#39;Hello, World!&#39;
        end</code></pre>
      HTML
      expect(result).to eq(expected)
    end

    it "renders code block without language" do
      block = NotionTestFixtures.get_block(:code, :no_language)
      result = renderer.render_block(block)
      expect(result).to eq('<pre class="notion-code"><code>plain code block without language</code></pre>')
    end

    it "renders code block with HTML template syntax correctly escaped" do
      block = NotionTestFixtures.get_block(:code, :with_html_template)
      result = renderer.render_block(block)
      expected = <<~HTML.strip
        <pre class="notion-code"><code class="language-html">&lt;!-- public/proxy/503.html --&gt;
        &lt;main&gt;
          &lt;h1&gt;일시 점검 중입니다&lt;/h1&gt;
          &lt;p&gt;
            {{ if .Message }}
              {{ .Message }}
            {{ else }}
              점검 중입니다. 잠시 후 다시 이용해 주세요.
            {{ end }}
          &lt;/p&gt;
        &lt;/main&gt;</code></pre>
      HTML
      expect(result).to eq(expected)
    end
  end

  describe "divider rendering" do
    it "renders divider" do
      block = NotionTestFixtures.get_block(:divider, :simple)
      result = renderer.render_block(block)
      expect(result).to eq('<hr>')
    end
  end

  describe "toggle rendering" do
    it "renders toggle with children" do
      block = NotionTestFixtures.get_block(:toggle, :simple)
      result = renderer.render_block(block)
      expect(result).to eq('<details><summary>Toggle header</summary><p>Hidden content inside toggle</p></details>')
    end
  end

  describe "callout rendering" do
    it "renders simple callout" do
      block = NotionTestFixtures.get_block(:callout, :simple)
      result = renderer.render_block(block)
      expect(result).to eq('<div class="notion-callout"><span class="notion-callout-icon">💡</span><div class="notion-callout-content">This is a callout!</div></div>')
    end

    it "renders colored callout" do
      block = NotionTestFixtures.get_block(:callout, :with_color)
      result = renderer.render_block(block)
      expect(result).to eq('<div class="notion-callout notion-color-red-background"><span class="notion-callout-icon">⚠️</span><div class="notion-callout-content">Important notice</div></div>')
    end
  end

  describe "image rendering" do
    it "renders external image with caption" do
      block = NotionTestFixtures.get_block(:image, :external)
      result = renderer.render_block(block)
      expect(result).to eq('<figure><img src="https://example.com/image.jpg" alt="Sample image caption"><figcaption>Sample image caption</figcaption></figure>')
    end

    it "renders file image without caption" do
      block = NotionTestFixtures.get_block(:image, :file)
      result = renderer.render_block(block)
      expect(result).to eq('<img src="https://notion.so/image.jpg" alt="">')
    end
  end

  describe "bookmark rendering" do
    it "renders bookmark" do
      block = NotionTestFixtures.get_block(:bookmark, :simple)
      
      # Mock the fetch_page_title method to avoid real HTTP requests in tests
      renderer.instance_eval do
        def fetch_page_title(url)
          "Example Domain"
        end
      end
      
      result = renderer.render_block(block)
      expected = '<div class="notion-bookmark"><a href="https://www.example.com" target="_blank" rel="noopener noreferrer">' +
                 '<div class="notion-bookmark-content"><div class="notion-bookmark-text">' +
                 '<div class="notion-bookmark-title">Example Domain</div>' +
                 '<div class="notion-bookmark-description">Example bookmark</div>' +
                 '<div class="notion-bookmark-link">https://www.example.com</div>' +
                 '</div></div></a></div>'
      expect(result).to eq(expected)
    end
  end

  describe "table rendering" do
    it "renders table with headers" do
      block = NotionTestFixtures.get_block(:table, :simple)
      result = renderer.render_block(block)
      expected = <<~HTML.strip
        <table>
        <thead>
        <tr><th>Header 1</th><th>Header 2</th><th>Header 3</th></tr>
        </thead>
        <tbody>
        <tr><td>Cell 1,1</td><td>Cell 1,2</td><td>Cell 1,3</td></tr>
        <tr><td>Cell 2,1</td><td>Cell 2,2</td><td>Cell 2,3</td></tr>
        </tbody>
        </table>
      HTML
      expect(result).to eq(expected)
    end
  end
end