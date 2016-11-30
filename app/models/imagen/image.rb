# frozen_string_literal: true
class Imagen::Image < Flexirest::Base
  include Imagen::ApiClient

  delete :delete, '/internal/images/:image_name'

  def self.upload(image, image_name = nil)
    response = if image_name.nil?
                 conn.post('/internal/images', image_param(image))
               else
                 conn.put("/internal/images/#{image_name}", image_param(image))
               end
    JSON.parse(response.body)['image_name']
  end

  def self.conn
    Faraday.new(Settings.imagen_url) do |config|
      config.request :multipart
      config.request :url_encoded
      config.adapter :net_http
      config.response :logger
      config.options.timeout = 5
      config.options.open_timeout = 2
    end
  end
  private_class_method :conn

  def self.image_param(image)
    { image: Faraday::UploadIO.new(image, 'image/png') }
  end
  private_class_method :image_param
end
