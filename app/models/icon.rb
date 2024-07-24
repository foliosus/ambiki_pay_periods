class Icon
  LOOKUP_MAP = {
    add: "circle-plus",
    edit: "pen-to-square"
  }

  def initialize(icon_name)
    @icon_name = icon_name
  end

  def to_s
    "<i class=\"fa-regular fa-#{ERB::Util.html_escape(fontawesome_icon_name)}\"></i>".html_safe
  end

  private def fontawesome_icon_name
    LOOKUP_MAP[@icon_name] || @icon_name
  end
end
