# frozen_string_literal: true

module EDM
  class WebResource
    include Mongoid::Document
    include Mongoid::Timestamps
    include RemoveBlankAttributes

    mount_uploader :media, MediaUploader

    belongs_to :edm_rights, class_name: 'CC::License', inverse_of: :edm_web_resources, optional: true
    embedded_in :edm_hasViews_for, class_name: 'ORE::Aggregation', inverse_of: :edm_hasViews
    embedded_in :edm_isShownBy_for, class_name: 'ORE::Aggregation', inverse_of: :edm_isShownBy

    validates :media, presence: true

    field :dc_description, type: String
    field :dc_rights, type: String

    rails_admin do
      visible false
      field :media, :carrierwave
      field :dc_description
      field :dc_rights
      field :edm_rights do
        inline_add false
        inline_edit false
      end
    end

    def rdf_about
      media&.url
    end
  end
end
