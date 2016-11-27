# frozen_string_literal: true
module Caja::ApiClient
  extend ActiveSupport::Concern

  included do
    base_url Settings.caja_url
    perform_caching false
    whiny_missing true
  end

  class_methods do
  end
end
