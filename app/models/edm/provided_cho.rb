# frozen_string_literal: true

# @see https://github.com/europeana/corelib/wiki/EDMObjectTemplatesProviders#edmProvidedCHO
module EDM
  class ProvidedCHO
    include Mongoid::Document
    include Mongoid::Timestamps
    include Mongoid::Uuid
    include AutocompletableModel
    include Blankness::Mongoid
    include CampaignValidatableModel
    include RDF::Graphable

    field :dc_creator, type: String
    field :dc_date, type: Date
    field :dc_description, type: String
    field :dc_identifier, type: String
    field :dc_language, type: String
    field :dc_relation, type: String
    field :dc_subject, type: String
    field :dc_title, type: String
    field :dc_type, type: String
    field :dcterms_created, type: Date
    field :dcterms_medium, type: String
    field :dcterms_spatial, type: String
    field :dcterms_temporal, type: String
    field :edm_currentLocation, type: String
    field :edm_type, type: String

    belongs_to :dc_contributor_agent,
               class_name: 'EDM::Agent', inverse_of: :dc_contributor_agent_for,
               optional: true, dependent: :destroy, touch: true
    belongs_to :edm_wasPresentAt,
               class_name: 'EDM::Event', inverse_of: :edm_wasPresentAt_for,
               optional: true, index: true
    has_and_belongs_to_many :dcterms_spatial_places,
             class_name: 'EDM::Place', inverse_of: nil
    has_many :dc_subject_agents,
             class_name: 'EDM::Agent', inverse_of: :dc_subject_agent_for,
             dependent: :destroy
    has_one :edm_aggregatedCHO_for,
            class_name: 'ORE::Aggregation', inverse_of: :edm_aggregatedCHO

    accepts_nested_attributes_for :dc_subject_agents, :dc_contributor_agent,
                                  allow_destroy: true
    accepts_nested_attributes_for :dcterms_spatial_places

    rejects_blank :dc_contributor_agent, :dc_subject_agents, :dcterms_spatial_places
    is_present_unless_blank :dc_contributor_agent, :dc_subject_agents, :dcterms_spatial_places, :edm_wasPresentAt

    has_rdf_predicate :dc_contributor_agent, RDF::Vocab::DC11.contributor
    has_rdf_predicate :dc_subject_agents, RDF::Vocab::DC11.subject
    has_rdf_predicate :dcterms_spatial_places, RDF::Vocab::DC.spatial

    excludes_from_rdf_output RDF::Vocab::EDM.wasPresentAt

    infers_rdf_language_tag_from :dc_language,
                                 on: [RDF::Vocab::DC11.title, RDF::Vocab::DC11.description]

    class << self
      def dc_language_enum
        I18nData.languages(I18n.locale).map { |code, name| [name, code.downcase] }
      end

      def edm_type_enum
        %w(IMAGE SOUND TEXT VIDEO 3D)
      end
    end

    delegate :edm_type_enum, :dc_language_enum, to: :class
    delegate :edm_dataProvider, :edm_provider, :draft?, :published?, :deleted?,
             to: :edm_aggregatedCHO_for, allow_nil: true

    before_validation :derive_edm_type_from_edm_isShownBy, unless: :edm_type?

    validates :dc_language, inclusion: { in: dc_language_enum.map(&:last) }, allow_blank: true
    validates :edm_type, inclusion: { in: edm_type_enum }, presence: true, if: :published?
    validates_associated :dc_contributor_agent, :dc_subject_agents, :dcterms_spatial_places
    validates_with PresenceOfAnyValidator,
                   of: %i(dc_subject dc_subject_agents dc_type dcterms_spatial dcterms_spatial_places dcterms_temporal),
                   if: :published?
    validates_with PresenceOfAnyValidator, of: %i(dc_title dc_description), if: :published?

    rails_admin do
      visible false
      object_label_method { :dc_title }

      list do
        field :edm_type
        field :dc_title
        field :dc_creator
        field :dc_contributor_agent
      end

      edit do
        field :edm_type, :enum
        field :dc_title
        field :dc_description, :text
        field :dc_creator
        field :dc_contributor_agent
        field :dc_identifier
        field :dc_date
        field :dc_relation
        field :dcterms_created
        field :dc_language, :enum
        field :dc_subject
        field :dc_subject_agents
        field :dc_type
        field :dcterms_medium
        field :dcterms_spatial_places
        field :edm_currentLocation
        field :edm_wasPresentAt do
          inline_add false
          inline_edit false
        end
      end
    end

    def rdf_uri
      RDF::URI.new("#{Rails.configuration.x.base_url}/contributions/#{uuid}")
    end

    def derive_edm_type_from_edm_isShownBy
      self.edm_type = edm_aggregatedCHO_for&.edm_isShownBy&.edm_type_from_media_content_type
    end

    alias_method :original_dcterms_spatial_places_attributes=, :dcterms_spatial_places_attributes=

    # Handle assignment of dcterms_spatial_places HABTM attributes
    #
    # If _destroy is present, do not *destroy* the place, just remove it from
    # the association.
    #
    # If rdf_about is present, look up whether an `EDM::Place` already exists
    # with that property, and if so use it in the association.
    #
    # TODO: abstract into a model concern
    # TODO: does this need to enforce either rdf_about or skos_prefLabel, not both?
    #   or does that belong on the EDM::Place class? i.e. if rdf_about is present,
    #   reject everything else
    def dcterms_spatial_places_attributes=(places_attributes)
      # Remove from attributes "destroyed" places.
      places_attributes.reject! do |_index, place_attributes|
        [1, '1', true, 'true'].include?(place_attributes[:_destroy])
      end

      # Lookup existing places by rdf_about
      places_attributes.each_pair do |_index, place_attributes|
        if place_attributes.key?(:rdf_about) && !place_attributes.key?(:id)
          if place = EDM::Place.where(rdf_about: place_attributes[:rdf_about]).first
            place_attributes[:id] = place.id.to_s
          end
        end
      end

      # Map of attributes to establish whether an existing place in the association
      # is still present by comparing against a whitelist of identifying fields.
      attributes_to_compare = %i(id rdf_about skos_prefLabel)
      comparision_map = attributes_to_compare.each_with_object({}) do |attribute, memo|
        memo[attribute] = places_attributes.values.map { |p| p[attribute] }.compact
      end

      # This needs to run before `dcterms_spatial_place_ids.delete` code below,
      # else `dcterms_spatial_place_ids` gets reset if places have been added,
      # preventing simultaneous removal
      send(:original_dcterms_spatial_places_attributes=, places_attributes)

      # Remove from association existing places not present in incoming attributes.
      dcterms_spatial_places.each do |place|
        unless comparision_map.any? { |attribute, values| values.include?(place.send(attribute).to_s) }
          dcterms_spatial_place_ids.delete(place.id)
        end
      end

      places_attributes
    end
  end
end
