# frozen_string_literal: true

module EDM
  class Agent
    include Mongoid::Document
    include Mongoid::Timestamps
    include Mongoid::Uuid
    include AutocompletableModel
    include Blankness::Mongoid
    include CampaignValidatableModel
    include RDF::Graphable

    field :rdaGr2_dateOfBirth, type: Date
    field :rdaGr2_dateOfDeath, type: Date
    field :rdaGr2_placeOfBirth, type: String
    field :rdaGr2_placeOfDeath, type: String
    field :skos_altLabel, type: String
    field :skos_prefLabel, type: String
    field :skos_note, type: String
    field :foaf_mbox, type: String
    field :foaf_name, type: String

    has_one :dc_creator_agent_for_edm_web_resource,
            class_name: 'EDM::WebResource', inverse_of: :dc_creator_agent
    has_one :dc_contributor_agent_for,
            class_name: 'EDM::ProvidedCHO', inverse_of: :dc_contributor_agent
    belongs_to :dc_subject_agent_for,
               class_name: 'EDM::ProvidedCHO', inverse_of: :dc_subject_agents,
               optional: true

    delegate :edm_provider, to: :dc_contributor_agent_for, allow_nil: true

    excludes_from_rdf_output RDF::Vocab::FOAF.name, if: :for_dc_contributor_agent?
    excludes_from_rdf_output RDF::Vocab::FOAF.mbox
    is_rdf_literal_if_blank_without RDF::Vocab::SKOS.prefLabel, RDF::Vocab::FOAF.name,
                                    if: :rdf_literalizable?

    # Only literalize on foaf:name or skos:prefLabel if predicate implies an
    # agent as the object, e.g. dc:contributor or dc:creator, but not dc:subject
    def rdf_literalizable?
      !dc_contributor_agent_for.nil? || !dc_creator_agent_for_edm_web_resource.nil?
    end

    def rdf_uri
      @rdf_uri ||= edm_provided_cho.nil? ? super : edm_provided_cho.rdf_uri + '#agent-' + uuid
    end

    def edm_provided_cho
      @edm_provided_cho ||= begin
        if !dc_contributor_agent_for.nil?
          dc_contributor_agent_for
        elsif !dc_subject_agent_for.nil?
          dc_subject_agent_for
        elsif !dc_creator_agent_for_edm_web_resource&.ore_aggregation&.edm_aggregatedCHO.nil?
          dc_creator_agent_for_edm_web_resource.ore_aggregation.edm_aggregatedCHO
        end
      end
    end

    def for_dc_contributor_agent?
      !dc_contributor_agent_for.nil?
    end

    rails_admin do
      visible false
      object_label_method { :foaf_name }
      field :foaf_name, :string
      field :skos_prefLabel
      field :foaf_mbox, :string
      field :rdaGr2_dateOfBirth
      field :rdaGr2_placeOfBirth
      field :rdaGr2_dateOfDeath
      field :rdaGr2_placeOfDeath
    end
  end
end
