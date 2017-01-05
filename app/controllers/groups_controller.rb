# frozen_string_literal: true
class GroupsController < ApplicationController
  before_action :set_paginated_param!, only: %i(search)
  before_action :set_group, only: %i(show update members invitees join left invite reject cancel)
  before_action :validate_private_info!, only: %i(show members)
  before_action :validate_member!, only: %i(update invitees left invite cancel)
  before_action :validate_no_member!, only: %i(join reject)

  def show; end

  def create
    group = Group.new(group_params)
    if group.save
      param_users.each { |user| InviteRel.create(from_node: group, to_node: user) }
      JoinRel.create(from_node: current_user, to_node: group)
      Caja::Folder.create(group_id: group.id, user_id: current_user.user_id)
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
                 .match(user: "User {user_id: #{current_user.user_id}}".dup)
                 .where_not('(user)-[:join]->(group)')
                 .where_not('(group)-[:invite]->(user)')

    @total_count = query.count(:group)
    groups = query.skip((@page - 1) * @per).limit(@per).pluck(:group)
    @groups = GroupDecorator.decorate_collection(groups)
  end

  def members
    @members = Cuenta::User.list(user_ids: @group.members.map(&:user_id).uniq).users
  end

  def invitees
    @invitees = Cuenta::User.list(user_ids: @group.invitees.map(&:user_id).uniq).users
  end

  def join
    if @group.public? || current_user.in?(@group.invitees)
      JoinRel.create(from_node: current_user, to_node: @group)
    else
      head :not_found
    end
  end

  def left
    current_user.groups.where(id: @group.id).each_rel(&:destroy)
    @group.destroy if @group.members.empty?
  end

  def invite
    invitees = param_users.map { |user| InviteRel.new(from_node: @group, to_node: user) }
    if invitees.all?(&:valid?)
      invitees.each(&:save)
    else
      head :unprocessable_entity
    end
  end

  def reject
    head_4xx and return unless current_user.in?(@group.invitees)
    @group.invitees.where(user_id: current_user.user_id).each_rel(&:destroy)
  end

  def cancel
    users = @group.invitees.where(user_id: params.fetch(:user_id))
    if users.present?
      users.each_rel(&:destroy)
    else
      head :not_found
    end
  end

  private

  def set_group
    @group = GroupDecorator.new(Group.find(params[:id]))
  end

  def validate_private_info!
    head_4xx if @group.is_private && !current_user.in?(@group.members) && !@group.invitees.where(user_id: current_user.user_id).exists?
  end

  def validate_member!
    head_4xx unless current_user.in?(@group.members)
  end

  def validate_no_member!
    head :forbidden if current_user.in?(@group.members)
  end

  def group_params
    params.permit(Group::PERMITTED_ATTRIBUTES).merge(upload_image: params.fetch(:image, {}))
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
