module NotionRubyRenderer
  class ImageHandler
    def handle(url, context = nil)
      raise NotImplementedError, "Subclasses must implement the handle method"
    end
  end

  class DefaultImageHandler < ImageHandler
    def handle(url, context = nil)
      url
    end
  end

  class CallbackImageHandler < ImageHandler
    def initialize(&block)
      @callback = block
    end

    def handle(url, context = nil)
      @callback.call(url, context) if @callback
    end
  end
end