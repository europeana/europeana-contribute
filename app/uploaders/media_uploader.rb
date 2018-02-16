# frozen_string_literal: true

class MediaUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  # storage :file
  storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    @store_dir ||= "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  process :set_content_type

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url(*args)
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process scale: [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  version :thumb_400x400, if: :supports_thumbnail? do
    process jpg_and_scale: [400, 400]
    def full_filename(_for_file)
      'thumbnail_400x400.jpg'
    end
  end

  version :thumb_200x200, if: :supports_thumbnail? do
    process jpg_and_scale: [200, 200]
    def full_filename(_for_file)
      'thumbnail_200x200.jpg'
    end
  end

  def supports_thumbnail?(picture)
    picture&.content_type&.match(%r(\Aimage/)) && model.persisted?
  end

  def jpg_and_scale(size_x = 400, size_y = 400)
    manipulate! do |img|
      img.format('jpg').resize("#{size_x}x#{size_y}")
    end
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  # def extension_whitelist
  #   %w(jpg jpeg gif png)
  # end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end

  ##
  # This overrides the default content_type which is based only on the file extension.
  # Instead this sets the content_type by making a system call to inspect the mime-type.
  #
  def set_content_type
    file_content_type = `file --b --mime-type '#{path}'`.strip
    if file.respond_to?(:content_type=)
      file.content_type = file_content_type
    else
      file.instance_variable_set(:@content_type, file_content_type)
    end
  end
end
