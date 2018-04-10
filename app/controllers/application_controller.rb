# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  around_action :set_current_user

  rescue_from CanCan::AccessDenied do |_exception|
    render_http_status(403)
  end

  rescue_from Mongoid::Errors::DocumentNotFound,
              OAI::NoMatchException do |_exception|
    render_http_status(404)
  end

  rescue_from ActionController::UnknownFormat do |_exception|
    render_http_status(406)
  end

  layout false

  private

  def current_user_ability
    @current_user_ability ||= Ability.new(current_user)
  end

  def current_user_can?(*args)
    current_user_ability.can?(*args)
  end

  def render_http_status(status)
    render plain: Rack::Utils::HTTP_STATUS_CODES[status], status: status
  end

  def set_current_user
    Current.user = current_user
    yield
  ensure
    # to address the thread variable leak issues in Puma/Thin webserver
    Current.user = nil
  end
end
