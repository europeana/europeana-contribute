# frozen_string_literal: true

class MediaController < ApplicationController
  # TODO: authorisation
  def show
    web_resource = EDM::WebResource.find_by(uuid: params[:uuid])
    redirect_to web_resource.media_url, status: 303
  end
end
