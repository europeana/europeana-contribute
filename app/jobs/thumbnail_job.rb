# frozen_string_literal: true

class ThumbnailJob < ApplicationJob
  queue_as :thumbnails

  def perform(web_resource_id, ore_aggregation_association)
    @web_resource_id = web_resource_id
    aggregation = ORE::Aggregation.find_by("#{ore_aggregation_association}._id": BSON::ObjectId.from_string(web_resource_id))
    case ore_aggregation_association
    when 'edm_hasViews'
      web_resource = aggregation.send(ore_aggregation_association.to_sym).select { |wr| wr._id == @web_resource_id }.first
    when 'edm_isShownBy'
      web_resource = aggregation.send(ore_aggregation_association.to_sym)
    else
      raise
    end
    web_resource.media.recreate_versions!(:thumb_400x400, :thumb_200x200)
  end
end
