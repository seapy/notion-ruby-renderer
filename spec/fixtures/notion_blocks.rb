# frozen_string_literal: true

module NotionTestFixtures
  BLOCKS = {
    paragraph: {
      simple: {
        "type" => "paragraph",
        "paragraph" => {
          "rich_text" => [
            {
              "type" => "text",
              "text" => { "content" => "This is a simple paragraph." }
            }
          ]
        }
      },
      formatted: {
        "type" => "paragraph",
        "paragraph" => {
          "rich_text" => [
            { "type" => "text", "text" => { "content" => "This is " } },
            { "type" => "text", "text" => { "content" => "bold" }, "annotations" => { "bold" => true } },
            { "type" => "text", "text" => { "content" => ", " } },
            { "type" => "text", "text" => { "content" => "italic" }, "annotations" => { "italic" => true } },
            { "type" => "text", "text" => { "content" => ", " } },
            { "type" => "text", "text" => { "content" => "underline" }, "annotations" => { "underline" => true } },
            { "type" => "text", "text" => { "content" => ", and " } },
            { "type" => "text", "text" => { "content" => "strikethrough" }, "annotations" => { "strikethrough" => true } },
            { "type" => "text", "text" => { "content" => " text." } }
          ]
        }
      },
      with_link: {
        "type" => "paragraph",
        "paragraph" => {
          "rich_text" => [
            { "type" => "text", "text" => { "content" => "Visit " } },
            { "type" => "text", "text" => { "content" => "OpenAI", "link" => { "url" => "https://openai.com" } } },
            { "type" => "text", "text" => { "content" => " for more info." } }
          ]
        }
      },
      colored: {
        "type" => "paragraph",
        "paragraph" => {
          "rich_text" => [
            { "type" => "text", "text" => { "content" => "Red text" }, "annotations" => { "color" => "red" } },
            { "type" => "text", "text" => { "content" => " and " } },
            { "type" => "text", "text" => { "content" => "blue background" }, "annotations" => { "color" => "blue_background" } }
          ],
          "color" => "gray_background"
        }
      }
    },

    heading_1: {
      simple: {
        "type" => "heading_1",
        "heading_1" => {
          "rich_text" => [
            { "type" => "text", "text" => { "content" => "Heading Level 1" } }
          ]
        }
      },
      with_toggle: {
        "type" => "heading_1",
        "heading_1" => {
          "rich_text" => [
            { "type" => "text", "text" => { "content" => "Toggleable Heading 1" } }
          ],
          "is_toggleable" => true
        }
      }
    },

    heading_2: {
      simple: {
        "type" => "heading_2",
        "heading_2" => {
          "rich_text" => [
            { "type" => "text", "text" => { "content" => "Heading Level 2" } }
          ]
        }
      }
    },

    heading_3: {
      simple: {
        "type" => "heading_3",
        "heading_3" => {
          "rich_text" => [
            { "type" => "text", "text" => { "content" => "Heading Level 3" } }
          ]
        }
      }
    },

    bulleted_list_item: {
      simple: {
        "type" => "bulleted_list_item",
        "bulleted_list_item" => {
          "rich_text" => [
            { "type" => "text", "text" => { "content" => "First bullet point" } }
          ]
        }
      },
      nested: {
        "type" => "bulleted_list_item",
        "bulleted_list_item" => {
          "rich_text" => [
            { "type" => "text", "text" => { "content" => "Parent bullet" } }
          ]
        },
        "has_children" => true,
        "children" => [
          {
            "type" => "bulleted_list_item",
            "bulleted_list_item" => {
              "rich_text" => [
                { "type" => "text", "text" => { "content" => "Nested bullet 1" } }
              ]
            }
          },
          {
            "type" => "bulleted_list_item",
            "bulleted_list_item" => {
              "rich_text" => [
                { "type" => "text", "text" => { "content" => "Nested bullet 2" } }
              ]
            }
          }
        ]
      }
    },

    numbered_list_item: {
      simple: {
        "type" => "numbered_list_item",
        "numbered_list_item" => {
          "rich_text" => [
            { "type" => "text", "text" => { "content" => "First numbered item" } }
          ]
        }
      },
      nested: {
        "type" => "numbered_list_item",
        "numbered_list_item" => {
          "rich_text" => [
            { "type" => "text", "text" => { "content" => "Parent numbered item" } }
          ]
        },
        "has_children" => true,
        "children" => [
          {
            "type" => "numbered_list_item",
            "numbered_list_item" => {
              "rich_text" => [
                { "type" => "text", "text" => { "content" => "Nested numbered 1" } }
              ]
            }
          }
        ]
      }
    },

    quote: {
      simple: {
        "type" => "quote",
        "quote" => {
          "rich_text" => [
            { "type" => "text", "text" => { "content" => "This is a quote block." } }
          ]
        }
      }
    },

    code: {
      simple: {
        "type" => "code",
        "code" => {
          "rich_text" => [
            { "type" => "text", "text" => { "content" => "def hello_world\n  puts 'Hello, World!'\nend" } }
          ],
          "language" => "ruby"
        }
      },
      no_language: {
        "type" => "code",
        "code" => {
          "rich_text" => [
            { "type" => "text", "text" => { "content" => "plain code block without language" } }
          ]
        }
      }
    },

    divider: {
      simple: {
        "type" => "divider",
        "divider" => {}
      }
    },

    toggle: {
      simple: {
        "type" => "toggle",
        "toggle" => {
          "rich_text" => [
            { "type" => "text", "text" => { "content" => "Toggle header" } }
          ]
        },
        "has_children" => true,
        "children" => [
          {
            "type" => "paragraph",
            "paragraph" => {
              "rich_text" => [
                { "type" => "text", "text" => { "content" => "Hidden content inside toggle" } }
              ]
            }
          }
        ]
      }
    },

    callout: {
      simple: {
        "type" => "callout",
        "callout" => {
          "rich_text" => [
            { "type" => "text", "text" => { "content" => "This is a callout!" } }
          ],
          "icon" => { "type" => "emoji", "emoji" => "💡" }
        }
      },
      with_color: {
        "type" => "callout",
        "callout" => {
          "rich_text" => [
            { "type" => "text", "text" => { "content" => "Important notice" } }
          ],
          "icon" => { "type" => "emoji", "emoji" => "⚠️" },
          "color" => "red_background"
        }
      }
    },

    image: {
      external: {
        "type" => "image",
        "image" => {
          "type" => "external",
          "external" => { "url" => "https://example.com/image.jpg" },
          "caption" => [
            { "type" => "text", "text" => { "content" => "Sample image caption" } }
          ]
        }
      },
      file: {
        "type" => "image",
        "image" => {
          "type" => "file",
          "file" => { "url" => "https://notion.so/image.jpg" }
        }
      }
    },

    bookmark: {
      simple: {
        "type" => "bookmark",
        "bookmark" => {
          "url" => "https://www.example.com",
          "caption" => [
            { "type" => "text", "text" => { "content" => "Example bookmark" } }
          ]
        }
      }
    },

    table: {
      simple: {
        "type" => "table",
        "table" => {
          "has_column_header" => true,
          "has_row_header" => false,
          "table_width" => 3
        },
        "has_children" => true,
        "children" => [
          {
            "type" => "table_row",
            "table_row" => {
              "cells" => [
                [{ "type" => "text", "text" => { "content" => "Header 1" } }],
                [{ "type" => "text", "text" => { "content" => "Header 2" } }],
                [{ "type" => "text", "text" => { "content" => "Header 3" } }]
              ]
            }
          },
          {
            "type" => "table_row",
            "table_row" => {
              "cells" => [
                [{ "type" => "text", "text" => { "content" => "Cell 1,1" } }],
                [{ "type" => "text", "text" => { "content" => "Cell 1,2" } }],
                [{ "type" => "text", "text" => { "content" => "Cell 1,3" } }]
              ]
            }
          },
          {
            "type" => "table_row",
            "table_row" => {
              "cells" => [
                [{ "type" => "text", "text" => { "content" => "Cell 2,1" } }],
                [{ "type" => "text", "text" => { "content" => "Cell 2,2" } }],
                [{ "type" => "text", "text" => { "content" => "Cell 2,3" } }]
              ]
            }
          }
        ]
      }
    },

    combined_list: {
      blocks: [
        {
          "type" => "bulleted_list_item",
          "bulleted_list_item" => {
            "rich_text" => [{ "type" => "text", "text" => { "content" => "Bullet 1" } }]
          }
        },
        {
          "type" => "bulleted_list_item",
          "bulleted_list_item" => {
            "rich_text" => [{ "type" => "text", "text" => { "content" => "Bullet 2" } }]
          }
        },
        {
          "type" => "numbered_list_item",
          "numbered_list_item" => {
            "rich_text" => [{ "type" => "text", "text" => { "content" => "Number 1" } }]
          }
        },
        {
          "type" => "numbered_list_item",
          "numbered_list_item" => {
            "rich_text" => [{ "type" => "text", "text" => { "content" => "Number 2" } }]
          }
        }
      ]
    }
  }

  def self.get_block(type, variant = :simple)
    BLOCKS.dig(type, variant)
  end

  def self.all_single_blocks
    BLOCKS.reject { |k, _| k == :combined_list }.map do |type, variants|
      variants.map { |variant, block| { type: type, variant: variant, block: block } }
    end.flatten
  end
end