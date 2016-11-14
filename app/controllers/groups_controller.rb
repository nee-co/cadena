class GroupsController < ApplicationController
  before_action :set_paginated_param!, only: %i(search)
  before_action :set_group, only: %i(show)
  before_action :validate_member!, only: %i(show)

  def index
    @groups = current_user.groups
    @invitations = current_user.invitations
  end

  def show
    member_ids = @group.users.map(&:user_id)
    invitation_ids = @group.invitations.map(&:user_id)
    user_ids = [member_ids, invitation_ids].flatten.uniq
    users = Cuenta::User.list(user_ids: user_ids).users

    @users = OpenStruct.new(
      members: users.select { |u| member_ids.include?(u.user_id) },
      invitations: users.select { |u| invitation_ids.include?(u.user_id) }
    )
  end

  def create
    @group = Group.new(group_params)
    if @group.valid?
      @group.save
      users.each { |user| InviteRel.create(from_node: @group, to_node: user) }
      JoinRel.create(from_node: current_user, to_node: @group)
      render status: :created
    else
      head :unprocessable_entity
    end
  end

  def search
    groups = Group.public.where(name: /.*#{params.fetch(:keyword)}.*/i)
    @groups = Neo4j::Paginated.create_from(Group.public, @page, @per)
  end

  private

  def set_group
    @group = Group.find(params[:id])
  end

  def validate_member!
    head_4xx unless current_user.in?(@group.users)
  end

  def group_params
    params.permit(Group::PERMITTED_ATTRIBUTES)
  end

  def users
    params.fetch(:user_ids, {}).uniq.map do |user_id|
      User.find_or_create_by(user_id: user_id)
    end
  end

  def head_4xx
    @group.is_private ? head(:not_found) : head(:forbidden)
  end
end
