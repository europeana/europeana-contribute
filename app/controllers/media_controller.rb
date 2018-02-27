# frozen_string_literal: true

class MediaController < ApplicationController
  def show
    web_resource = EDM::WebResource.find_by(uuid: params[:uuid])
    authorize! :show, web_resource&.ore_aggregation&.story
    redirect_to web_resource.media_url, status: 303
  end
end
