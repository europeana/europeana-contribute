# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  rescue_from CanCan::AccessDenied, with: :http_403_forbidden

  private

  def http_403_forbidden
    render plain: 'Forbidden', status: 403
  end
end
