# frozen_string_literal: true
module Caja
  class Folder < Flexirest::Base
    include Caja::ApiClient

    post :create, '/internal/folders'
    post :cleanup, '/internal/cleanup'
  end
end
