class Api::V1::ApiController < ApplicationController
  acts_as_token_authentication_handler_for User, fallback: :none
  before_action :authenticate

  def json_success(info, data = {})
    render status: 200,
    json: { success: true, info: info, data: data }
  end

  def json_bad_request(info, data = {})
    render status: 400,
    json: { success: false, info: info, data: data }
  end

  def json_unauthorized(info, data = {})
    render status: 401,
    json: { success: false, info: info, data: data }
  end

  def json_not_found(info, data = {})
    render status: 404,
    json: { success: false, info: info, data: data }
  end

  def json_forbidden(info)
    render status: 404,
    json: { success: false, info: info }
  end

  private
  def authenticate
    authenticate_or_request_with_http_token do |token, options|
      @current_user = User.find_by(authentication_token: token)
      if @current_user.present?
        return @current_user
      else
        json_forbidden("Auth token invalid, please relogin")
      end
    end
  end

end