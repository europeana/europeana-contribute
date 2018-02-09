# frozen_string_literal: true

module EDM
  class WebResource
    include Mongoid::Document
    include Mongoid::Timestamps
    include Blankness::Mongoid
    include RDFModel

    mount_uploader :media, MediaUploader

    belongs_to :edm_rights,
               class_name: 'CC::License', inverse_of: :edm_rights_for_edm_web_resources,
               optional: true
    belongs_to :dc_creator_agent,
               class_name: 'EDM::Agent', inverse_of: :dc_creator_agent_for_edm_web_resource,
               optional: true, dependent: :destroy, touch: true
    has_one :edm_hasView_for,
            class_name: 'ORE::Aggregation', inverse_of: :edm_hasViews
    has_one :edm_isShownBy_for,
            class_name: 'ORE::Aggregation', inverse_of: :edm_isShownBy

    accepts_nested_attributes_for :dc_creator_agent

    rejects_blank :dc_creator_agent
    is_present_unless_blank :dc_creator_agent, :edm_rights

    checks_blankness_with :media_blank?

    has_rdf_predicate :dc_creator_agent, RDF::Vocab::DC11.creator

    # validates :media, presence: true
    validate :europeana_supported_media_mime_type, unless: proc { |wr| wr.media.blank? }
    validates_associated :dc_creator_agent

    field :dc_description, type: String
    field :dc_rights, type: String
    field :dc_type, type: String
    field :dcterms_created, type: Date

    rails_admin do
      visible false
      field :media, :carrierwave
      field :dc_description
      field :dc_rights
      field :dc_type
      field :dcterms_created
      field :dc_creator_agent
      field :edm_rights do
        inline_add false
        inline_edit false
      end
    end

    ALLOWED_CONTENT_TYPES = %w(
      image/jpeg
      image/bmp
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
        end.flatten.join(', ')
      end

      def allowed_content_types
        ALLOWED_CONTENT_TYPES.join(', ')
      end
    end

    def rdf_uri
      RDF::URI.parse(rdf_about)
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

    ##
    # Validation method for the web resource's media to only allow certain types of content.
    def europeana_supported_media_mime_type
      errors.add(:media, I18n.t('errors.messages.inclusion')) unless ALLOWED_CONTENT_TYPES.include?(media&.content_type)
    end
  end
end
