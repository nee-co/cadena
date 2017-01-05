# frozen_string_literal: true
class GroupDecorator < Draper::Decorator
  delegate_all

  def image
    File.join(Settings.static_image_url, object.image)
  end

  def type
    "group"
  end

  def folder_id
    Caja::Folder.top_id(group_id: object.id).id
  end
end
