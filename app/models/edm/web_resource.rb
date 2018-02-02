# frozen_string_literal: true

module EDM
  class WebResource
    include Mongoid::Document
    include Mongoid::Timestamps
    include RDFModel
    include RemoveBlankAttributes

    mount_uploader :media, MediaUploader

    belongs_to :edm_rights, class_name: 'CC::License', inverse_of: :edm_web_resources, optional: true
    embeds_one :dc_creator, class_name: 'EDM::Agent', inverse_of: :dc_creator_for_edm_webResource,
                            cascade_callbacks: true
    embedded_in :edm_hasView_for, class_name: 'ORE::Aggregation', inverse_of: :edm_hasViews
    embedded_in :edm_isShownBy_for, class_name: 'ORE::Aggregation', inverse_of: :edm_isShownBy

    accepts_nested_attributes_for :dc_creator

    # validates :media, presence: true
    validate :europeana_supported_media_mime_type, unless: proc { |wr| wr.media.blank? }

    field :dc_description, type: String
    field :dc_rights, type: String
    field :dc_type, type: String
    field :dcterms_created, type: Date

    after_create :queue_thumbnail

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
      image/gif
      image/png
      video/mp4
      video/webm
      audio/mp3
      audio/mpeg3
      audio/x-mpeg-3
      audio/webm
      audio/wav
      audio/x-wav
      application/pdf
    ).freeze

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

    def blank_attributes?
      media.blank? && super
    end

    ##
    # Validation method for the web resource's media to only allow certain types of content.
    def europeana_supported_media_mime_type
      errors.add(:media, I18n.t('errors.messages.inclusion')) unless ALLOWED_CONTENT_TYPES.include?(media&.content_type)
    end

    def queue_thumbnail
      return unless media&.content_type&.match(%r(\Aimage/)) && persisted?
      if edm_isShownBy_for
        ore_aggregation_association = 'edm_isShownBy'
      elsif edm_hasView_for
        ore_aggregation_association = 'edm_hasViews'
      end
      ThumbnailJob.perform_later(id.to_s, ore_aggregation_association)
    end
  end
end
