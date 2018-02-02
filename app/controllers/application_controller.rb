# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  rescue_from CanCan::AccessDenied, with: :http_403_forbidden
  rescue_from Mongoid::Errors::DocumentNotFound, with: :http_404_not_found

  private

  def http_403_forbidden
    render plain: 'Forbidden', status: 403
  end

  def http_404_not_found
    render plain: 'Not Found', status: 404
  end
end
