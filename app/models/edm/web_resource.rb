# frozen_string_literal: true

module EDM
  class WebResource
    include Mongoid::Document
    include Mongoid::Timestamps
    include Mongoid::Uuid
    include ArrayOfAttributeValidation
    include Blankness::Mongoid
    include CampaignValidatableModel
    include RDF::Graphable

    mount_uploader :media, MediaUploader

    belongs_to :edm_rights,
               class_name: 'CC::License', inverse_of: :edm_rights_for_edm_web_resources,
               optional: true
    belongs_to :dc_creator_agent,
               class_name: 'EDM::Agent', inverse_of: :dc_creator_agent_for_edm_web_resource,
               optional: true, dependent: :destroy, touch: true
    belongs_to :edm_isShownBy_for,
               optional: true, class_name: 'ORE::Aggregation', inverse_of: :edm_isShownBy,
               index: true, touch: true
    belongs_to :edm_hasView_for,
               optional: true, class_name: 'ORE::Aggregation', inverse_of: :edm_hasViews,
               index: true, touch: true

    accepts_nested_attributes_for :dc_creator_agent

    rejects_blank :dc_creator_agent
    is_present_unless_blank :dc_creator_agent

    checks_blankness_with :media_blank?

    has_rdf_predicate :dc_creator_agent, RDF::Vocab::DC11.creator

    infers_rdf_language_tag_from :dc_language,
                                 on: RDF::Vocab::DC11.description

    delegate :draft?, :published?, :deleted?, :dc_language, :campaign,
             to: :ore_aggregation, allow_nil: true

    validates :media, presence: true, if: :published?
    validates :edm_rights, presence: true, unless: :media_blank?
    validate :europeana_supported_media_mime_type, unless: :media_blank?
    validates_associated :dc_creator_agent

    after_validation :remove_media!, unless: proc { |wr| wr.errors.empty? }

    field :dc_creator, type: ArrayOf.type(String), default: []
    field :dc_description, type: ArrayOf.type(String), default: []
    field :dc_rights, type: ArrayOf.type(String), default: []
    field :dc_type, type: ArrayOf.type(String), default: []
    field :dcterms_created, type: ArrayOf.type(Date), default: []

    after_save :queue_thumbnail

    rails_admin do
      visible false
      field :media, :carrierwave
      field :dc_description
      field :dc_rights
      field :dc_type
      field :dcterms_created
      field :dc_creator
      field :edm_rights do
        inline_add false
        inline_edit false
      end
    end

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
    end

    def rdf_uri
      RDF::URI.new("#{Rails.configuration.x.base_url}/media/#{uuid}")
    end

    def rdf_about
      media&.url
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

    def media_blank?
      media.blank?
    end

    def ore_aggregation
      edm_isShownBy_for || edm_hasView_for
    end

    ##
    # Validation method for the web resource's media to only allow certain types of content.
    def europeana_supported_media_mime_type
      unless ALLOWED_CONTENT_TYPES.include?(media&.content_type)
        errors.add(:media, I18n.t('errors.messages.inclusion'))
      end
    end

    def queue_thumbnail
      return unless media_changed?
      ThumbnailJob.perform_later(id.to_s)
    end
  end
end
