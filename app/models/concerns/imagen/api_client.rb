# frozen_string_literal: true
module Imagen::ApiClient
  extend ActiveSupport::Concern

  included do
    base_url Settings.imagen_url
    perform_caching false
    whiny_missing true
  end

  class_methods do
  end
end
