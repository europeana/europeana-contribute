# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include CurrentUserHelper

  protect_from_forgery with: :exception
  around_action :set_current_user

  rescue_from CanCan::AccessDenied do |_exception|
    render_http_status(403)
  end

  rescue_from Mongoid::Errors::DocumentNotFound,
              OAI::NoMatchException, PagesController::NotFoundError do |_exception|
    render_http_status(404)
  end

  rescue_from ActionController::UnknownFormat do |_exception|
    render_http_status(406)
  end

  layout false

  private

  def render_http_status(status)
    render plain: Rack::Utils::HTTP_STATUS_CODES[status], status: status
  end
end
