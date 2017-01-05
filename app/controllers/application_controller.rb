# frozen_string_literal: true
class ApplicationController < ActionController::API
  before_action :authenticate_account!

  def current_user
    if @current_user.nil? && request.env['HTTP_X_CONSUMER_CUSTOM_ID'].present?
      @current_user = User.find_or_create_by(user_id: request.env['HTTP_X_CONSUMER_CUSTOM_ID'])
    end
    @current_user
  end

  protected

  def authenticate_account!
    head :unauthorized and return unless current_user.present?
  end

  def set_paginated_param!
    head :unprocessable_entity unless %i(page per).all?(&params.method(:include?))
    @page = params[:page].to_i
    @per = params[:per].to_i
  end

  def set_limit_offset_param!
    head :unprocessable_entity unless %i(limit offset).all?(&params.method(:include?))
    @limit = params[:limit].to_i
    @offset = params[:offset].to_i
  end
end
