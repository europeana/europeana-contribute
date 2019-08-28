# frozen_string_literal: true

class PagesController < ApplicationController
  include ContentfulHelper

  class NotFoundError < StandardError; end

  def show
    identifier = params[:identifier] == '/' ? 'home' : params[:identifier]
    @page = contentful_entry(identifier: identifier, mode: params[:mode])

    fail NotFoundError if @page.nil?
  end
end
