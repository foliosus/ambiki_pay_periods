require "test_helper"

class IconTest < ActiveSupport::TestCase
  should "render to string" do
    expected = "<i class=\"fa-regular fa-pen\"></i>"
    icon = Icon.new(:pen)
    assert_equal expected, icon.to_s
  end

  should "translate the icon name if necessary and render to string" do
    Icon::LOOKUP_MAP.each do |icon_name, fontawesome_icon_name|
      expected = "<i class=\"fa-regular fa-#{fontawesome_icon_name}\"></i>"
      icon = Icon.new(icon_name)
      assert_equal expected, icon.to_s
    end
  end
end
