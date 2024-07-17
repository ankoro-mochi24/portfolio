class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name]) # サインアップ時にnameパラメータを許可
    devise_parameter_sanitizer.permit(:account_update, keys: [:name]) # アカウント更新時にnameパラメータを許可
  end
end
