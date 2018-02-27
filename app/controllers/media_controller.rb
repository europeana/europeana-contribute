# frozen_string_literal: true

class MediaController < ApplicationController
  def show
    web_resource = EDM::WebResource.find_by(uuid: params[:uuid])
    authorize! :show, web_resource&.ore_aggregation&.story
    redirect_to redirect_location(web_resource), status: 303
  end

  private

  def redirect_location(web_resource)
    case params[:size]
    when 'w200'
      web_resource.media.url(:thumb_200x200)
    when 'w400'
      web_resource.media.url(:thumb_400x400)
    else
      web_resource.media_url
    end
  end
end
