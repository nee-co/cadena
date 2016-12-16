# frozen_string_literal: true
module Caja
  class Folder < Flexirest::Base
    include Caja::ApiClient

    get :top_id, '/internal/folders'
    post :create, '/internal/folders'
    post :cleanup, '/internal/folders/cleanup'
  end
end
