module NotionRubyRenderer
  class ColorMapper
    DEFAULT_COLORS = {
      "gray" => "#787774",
      "brown" => "#9F6B53",
      "orange" => "#D9730D",
      "yellow" => "#CB912F",
      "green" => "#448361",
      "blue" => "#337EA9",
      "purple" => "#9065B0",
      "pink" => "#C14C8A",
      "red" => "#D44C47",
      "gray_background" => "#F1F1EF",
      "brown_background" => "#F4EEEE",
      "orange_background" => "#FBECDD",
      "yellow_background" => "#FBF3DB",
      "green_background" => "#EDF3EC",
      "blue_background" => "#E7F3F8",
      "purple_background" => "#F6F3F9",
      "pink_background" => "#FAF1F5",
      "red_background" => "#FDEBEC"
    }.freeze

    def initialize(custom_colors = {})
      @colors = DEFAULT_COLORS.merge(custom_colors)
    end

    def get_color(color_name)
      @colors[color_name] || color_name
    end
  end
end