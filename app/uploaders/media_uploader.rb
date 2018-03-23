# frozen_string_literal: true

class MediaUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  # storage :file
  storage :fog
  cache_storage :fog

  process :set_content_type

  version :w400, if: :supports_thumbnail? do
    process jpg_and_scale: [400]
    def full_filename(_for_file)
      model.media_basename + '.w400.jpeg'
    end
  end

  version :w200, if: :supports_thumbnail? do
    process jpg_and_scale: [200]
    def full_filename(_for_file)
      model.media_basename + '.w200.jpeg'
    end
  end

  def self.image?(file)
    file.content_type.present? && # content_type will be false if image is removed
      !file.content_type.match(%r(\Aimage/)).nil?
  end

  # Always store files in object storage root directory
  def store_dir
    nil
  end

  def filename
    file.nil? ? nil : model.media_filename
  end

  def filename_extension
    MIME::Types[file&.content_type]&.first&.preferred_extension || 'tmp'
  end

  def move_to_cache
    true
  end

  def move_to_store
    true
  end

  def fog_attributes
    super.tap do |attributes|
      if image? && changed?
        attributes['x-amz-meta-image-width'] ||= image.width.to_s
        attributes['x-amz-meta-image-height'] ||= image.height.to_s
      end
    end
  end

  def changed?
    model.send(:"#{mounted_as}_changed?")
  end

  def image?
    self.class.image?(file)
  end

  def image
    @image ||= MiniMagick::Image.open(url)
  end

  def supports_thumbnail?(picture)
    model.persisted? && self.class.image?(picture)
  end

  def jpg_and_scale(size_x = nil, size_y = nil)
    manipulate! do |img|
      img.format('jpg').resize("#{size_x}x#{size_y}")
    end
  end

  ##
  # This overrides the default content_type which is based only on the file extension.
  # Instead this sets the content_type by making a system call to inspect the mime-type.
  def set_content_type
    file_content_type = `file --b --mime-type '#{path}'`.strip
    if file.respond_to?(:content_type=)
      file.content_type = file_content_type
    else
      file.instance_variable_set(:@content_type, file_content_type)
    end
  end

  def blank?
    super || model.send(:"remove_#{mounted_as}?")
  end
end
