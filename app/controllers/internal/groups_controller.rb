class Internal::GroupsController < ApplicationController
  skip_before_action :authenticate_account!
  before_action :set_group, only: %i(show)

  def index
    user = User.find_or_create_by(user_id: params.fetch(:user_id))
    @groups = user.groups
  end

  def show
    render json: { "member_ids": @group.users.map(&:user_id) }
  end

  private

  def set_group
    @group = Group.find(params[:id])
  end
end
