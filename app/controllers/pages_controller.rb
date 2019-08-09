# frozen_string_literal: true

class PagesController < ApplicationController
  include ContentfulHelper

  class NotFoundError < StandardError; end

  def show
    @page = contentful_entry(identifier: params[:identifier])

    fail NotFoundError if @page.nil?
  end
end
