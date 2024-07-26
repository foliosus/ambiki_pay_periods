class Icon
  LOOKUP_MAP = {
    add: "square-plus",
    alert: "circle-xmark",
    delete: "trash-can",
    edit: "pen-to-square",
    go_left: "circle-left",
    go_right: "circle-right",
    notice: "circle-check",
  }

  def initialize(icon_name)
    @icon_name = icon_name.to_sym
  end

  def to_s
    "<i class=\"fa-regular fa-#{ERB::Util.html_escape(fontawesome_icon_name)}\"></i>".html_safe
  end

  private def fontawesome_icon_name
    LOOKUP_MAP[@icon_name] || @icon_name
  end
end
