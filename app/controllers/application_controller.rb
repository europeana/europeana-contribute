# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  rescue_from CanCan::AccessDenied do |_exception|
    render_http_status(403)
  end

  rescue_from Mongoid::Errors::DocumentNotFound do |_exception|
    render_http_status(404)
  end

  rescue_from ActionController::UnknownFormat do |_exception|
    render_http_status(406)
  end

  private

  def render_http_status(status)
    render plain: Rack::Utils::HTTP_STATUS_CODES[status], status: status
  end
end
