class ApplicationController < ActionController::API

  before_action :authenticate_account!

  def current_user
    if @current_user.nil? && request.env["HTTP_X_CONSUMER_CUSTOM_ID"].present?
      @current_user = Cuenta::User.find(request.env["HTTP_X_CONSUMER_CUSTOM_ID"])
    end
    @current_user
  end

  protected

  def authenticate_account!
    head :unauthorized and return unless current_user.present?
  end
end
