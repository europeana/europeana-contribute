# frozen_string_literal: true

module EDM
  class WebResource
    include Mongoid::Document
    include Mongoid::Timestamps
    include Mongoid::Uuid
    include ArrayOfAttributeValidation
    include AutocompletableModel
    include Blankness::Mongoid::Attributes
    include Blankness::Mongoid::Relations
    include CampaignValidatableModel
    include RecordableDeletion
    include RDF::Graphable

    mount_uploader :media, MediaUploader

    belongs_to :edm_rights,
               class_name: 'CC::License', inverse_of: :edm_rights_for_edm_web_resources,
               optional: true
    belongs_to :dc_creator_agent,
               class_name: 'EDM::Agent', inverse_of: :dc_creator_agent_for_edm_web_resource,
               optional: true, dependent: :destroy
    belongs_to :edm_isShownBy_for,
               optional: true, class_name: 'ORE::Aggregation', inverse_of: :edm_isShownBy,
               index: true
    belongs_to :edm_hasView_for,
               optional: true, class_name: 'ORE::Aggregation', inverse_of: :edm_hasViews,
               index: true

    accepts_nested_attributes_for :dc_creator_agent

    rejects_blank :dc_creator_agent
    is_present_unless_blank :dc_creator_agent

    checks_blankness_with :media_blank?

    has_rdf_predicate :dc_creator_agent, RDF::Vocab::DC11.creator

    infers_rdf_language_tag_from :dc_language,
                                 on: RDF::Vocab::DC11.description

    delegate :draft?, :published?, :deleted?, :dc_language, :campaign, :ever_published?,
             to: :ore_aggregation, allow_nil: true

    validates :media, presence: true, if: :published?
    validate :europeana_supported_media_mime_type, unless: :media_blank?
    validate :media_size_permitted, unless: :media_blank?
    validates_associated :dc_creator_agent

    before_destroy :remove_versions
    before_destroy :create_deleted_resource, if: :ever_published?

    field :dc_creator, type: ArrayOf.type(String), default: []
    field :dc_description, type: ArrayOf.type(String), default: []
    field :dc_rights, type: ArrayOf.type(String), default: []
    field :dc_type, type: ArrayOf.type(String), default: []
    field :dcterms_created, type: ArrayOf.type(Date), default: []

    identifies_deleted_resources_by :uuid

    after_save :queue_thumbnail

    ALLOWED_CONTENT_TYPES = %w(
      image/jpeg
      image/bmp
      image/x-ms-bmp
      image/x-windows-bmp
      image/tiff
      image/gif
      image/png
      video/mp4
      video/webm
      audio/mp3
      audio/mpeg
      audio/mpeg3
      audio/x-mpeg-3
      audio/webm
      audio/wav
      audio/x-wav
      application/pdf
    ).freeze

    MAX_MEDIA_SIZE = 50.megabytes

    class << self
      def allowed_extensions
        ALLOWED_CONTENT_TYPES.map do |content_type|
          MIME::Types[content_type].map do |mime_type|
            mime_type.extensions.map { |extension| ".#{extension}" }
          end
        end.uniq.flatten.join(', ')
      end

      def allowed_content_types
        ALLOWED_CONTENT_TYPES.join(', ')
      end

      def max_media_size
        MAX_MEDIA_SIZE
      end
    end

    def rdf_uri
      RDF::URI.new("#{Rails.configuration.x.base_url}/media/#{uuid}")
    end

    def rdf_about
      media&.url
    end

    def remove_versions
      media.versions.each_key { |key| media.send(key).remove! }
    end

    def edm_type_from_media_content_type
      case media&.content_type
      when %r{\Aimage/}
        'IMAGE'
      when %r{\Aaudio/}
        'SOUND'
      when %r{\Avideo/}
        'VIDEO'
      when %r{\Atext/}, 'application/pdf'
        'TEXT'
      else
        'IMAGE'
      end
    end

    def media_filename
      ext = media&.filename_extension.nil? ? '' : ".#{media.filename_extension}"
      "#{media_basename}#{ext}"
    end

    def media_basename
      uuid || id.to_s
    end

    def media_blank?
      media.nil? || media.file.nil?
    end

    def ore_aggregation
      edm_isShownBy_for || edm_hasView_for
    end

    ##
    # Validation method for the web resource's media to only allow certain types of content.
    def europeana_supported_media_mime_type
      unless ALLOWED_CONTENT_TYPES.include?(media&.content_type)
        errors.add(:media, I18n.t('errors.messages.inclusion'))
        flag_for_media_removal!
      end
    end

    def media_size_permitted
      limit = MAX_MEDIA_SIZE
      if (media&.file&.size || 0) > limit
        error_msg = I18n.t('contribute.form.validation.media_size', size: ::ApplicationController.helpers.number_to_human_size(limit))
        errors.add(:media, error_msg)
        flag_for_media_removal!
      end
    end

    def flag_for_media_removal!
      @flagged_for_media_removal = true
    end

    def flagged_for_media_removal?
      @flagged_for_media_removal == true
    end

    def queue_thumbnail
      return unless media_changed?
      ThumbnailJob.perform_later(id.to_s)
    end
  end
end
