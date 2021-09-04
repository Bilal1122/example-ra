class Api::V1::ApiController < ApplicationController
  acts_as_token_authentication_handler_for User, fallback: :none

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
    json: { success: false, info: info, data: data }
  end

end