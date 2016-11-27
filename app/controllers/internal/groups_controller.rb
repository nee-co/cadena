# frozen_string_literal: true
class Internal::GroupsController < ApplicationController
  skip_before_action :authenticate_account!

  def index
    user = User.find_or_create_by(user_id: params.fetch(:user_id))
    @groups = GroupDecorator.decorate_collection(user.groups)
  end
end
