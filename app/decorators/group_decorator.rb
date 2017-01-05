# frozen_string_literal: true
class GroupDecorator < Draper::Decorator
  delegate_all

  def image
    File.join(Settings.static_image_url, object.image)
  end

  def type
    "group"
  end
end
