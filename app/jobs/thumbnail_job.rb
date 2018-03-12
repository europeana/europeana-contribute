# frozen_string_literal: true

class ThumbnailJob < ApplicationJob
  queue_as :thumbnails

  def perform(web_resource_id)
    web_resource = EDM::WebResource.find(web_resource_id)
    web_resource.media.recreate_versions!(:thumb_400x400, :thumb_200x200)
  end
end
