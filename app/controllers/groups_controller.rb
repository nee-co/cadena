class GroupsController < ApplicationController
  before_action :set_paginated_param!, only: %i(search)

  def index
    @groups = current_user.groups
    @invitations = current_user.invitations
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

  def group_params
    params.permit(Group::PERMITTED_ATTRIBUTES)
  end

  def users
    params.fetch(:user_ids, {}).uniq.map do |user_id|
      User.find_or_create_by(user_id: user_id)
    end
  end
end
