# frozen_string_literal: true
class TrayController < ApplicationController
  before_action :set_limit_offset_param!

  def index
    @elements = GroupDecorator.decorate_collection(current_user.groups.skip(@offset).limit(@limit))
    render "elements"
  end

  def invitations
    @elements = GroupDecorator.decorate_collection(current_user.invitations.skip(@offset).limit(@limit))
    render "elements"
  end
end
