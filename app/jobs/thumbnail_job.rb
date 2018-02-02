# frozen_string_literal: true

class ThumbnailJob < ApplicationJob
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
    @uploader = web_resource.media
    %w(200x200 400x400).each do |size|
      thumbnail_path = transform_image(@uploader.url, size)
      upload_image(thumbnail_path)
      cleanup(thumbnail_path)
    end
  end

  def upload_image(thumbnail_path)
    @uploader.store!(File.new(thumbnail_path))
  end

  def cleanup(thumbnail_path)
    File.delete(thumbnail_path)
    parent_dir = File.dirname(thumbnail_path)
    FileUtils.remove_dir(parent_dir) if Dir.empty?(parent_dir)
  end

  def transform_image(url, new_size = '200x200')
    image = MiniMagick::Image.open(url)
    image.resize new_size
    image.format 'png'
    thumbnail_path = "tmp/#{@web_resource_id}/thumbnail-#{new_size}.png"
    FileUtils.mkpath("tmp/#{@web_resource_id}")
    image.write(thumbnail_path)
    image.destroy!
    thumbnail_path
  end
end
