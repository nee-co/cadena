class GroupDecorator < Draper::Decorator
  delegate_all

  def image
    # TODO: Imagenに対応する
    # File.join(Settings.static_url, object.image)
    Settings.static_url
  end
end
