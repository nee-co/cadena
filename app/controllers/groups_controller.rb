# frozen_string_literal: true
class GroupsController < ApplicationController
  before_action :set_paginated_param!, only: %i(search)
  before_action :set_group, only: %i(show update join left invite reject cancel folder)
  before_action :validate_member!, only: %i(show update left invite cancel folder)
  before_action :validate_no_member!, only: %i(join reject)

  def index
    @groups = GroupDecorator.decorate_collection(current_user.groups)
    @invitations = current_user.invitations
  end

  def show
    @users = fetch_group_users
  end

  def create
    group = Group.new(group_params)
    if group.valid?
      group.save
      param_users.each { |user| InviteRel.create(from_node: group, to_node: user) }
      JoinRel.create(from_node: current_user, to_node: group)
      @group = GroupDecorator.new(group)
      render status: :created
    else
      head :unprocessable_entity
    end
  end

  def update
    if @group.update(group_params)
      @group = GroupDecorator.new(@group)
    else
      head :unprocessable_entity
    end
  end

  def search
    query = Group.public.where(name: /.*#{params.fetch(:keyword)}.*/i)
                 .query_as(:group)
                 .match(user: "User {user_id: #{current_user.user_id}}")
                 .where_not('(user)-[:join]->(group)')
                 .where_not('(group)-[:invite]->(user)')

    @total_count = query.count(:group)
    groups = query.skip((@page - 1) * @per).limit(@per).pluck(:group)
    @groups = GroupDecorator.decorate_collection(groups)
  end

  def join
    if @group.public? || current_user.in?(@group.invitations)
      JoinRel.create(from_node: current_user, to_node: @group)
    else
      head :not_found
    end
  end

  def left
    current_user.groups.where(id: @group.id).each_rel(&:destroy)
    return unless @group.members.empty?
    @group.invitations.each_rel(&:destroy)
    @group.destroy
    Caja::Folder.cleanup(group_id: @group.id)
  end

  def invite
    invitations = param_users.map { |user| InviteRel.new(from_node: @group, to_node: user) }
    if invitations.all?(&:valid?)
      invitations.each(&:save)
    else
      head :unprocessable_entity
    end
  end

  def reject
    head_4xx and return unless current_user.in?(@group.invitations)
    @group.invitations.where(user_id: current_user.user_id).each_rel(&:destroy)
  end

  def cancel
    users = @group.invitations.where(user_id: params.fetch(:user_id))
    if users.present?
      users.each_rel(&:destroy)
    else
      head :not_found
    end
  end

  def folder
    Caja::Folder.create(group_id: @group.id)
  end

  private

  def set_group
    @group = GroupDecorator.new(Group.find(params[:id]))
  end

  def fetch_group_users
    member_ids = @group.members.map(&:user_id)
    invitation_ids = @group.invitations.map(&:user_id)
    users = Cuenta::User.list(user_ids: [member_ids, invitation_ids].uniq).users

    OpenStruct.new(
      members: users.select { |u| member_ids.include?(u.id) },
      invitations: users.select { |u| invitation_ids.include?(u.id) }
    )
  end

  def validate_member!
    head_4xx unless current_user.in?(@group.members)
  end

  def validate_no_member!
    head :forbidden if current_user.in?(@group.members)
  end

  def group_params
    params.permit(Group::PERMITTED_ATTRIBUTES)
  end

  def param_users
    params.fetch(:user_ids, []).uniq.map do |user_id|
      User.find_or_create_by(user_id: user_id)
    end
  end

  def head_4xx
    @group.is_private ? head(:not_found) : head(:forbidden)
  end
end
