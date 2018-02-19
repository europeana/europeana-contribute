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

    has_one :dc_creator_agent_for_edm_web_resource,
            class_name: 'EDM::WebResource', inverse_of: :dc_creator_agent
    has_one :dc_contributor_agent_for,
            class_name: 'EDM::ProvidedCHO', inverse_of: :dc_contributor_agent

    field :rdaGr2_dateOfBirth, type: Date
    field :rdaGr2_dateOfDeath, type: Date
    field :rdaGr2_placeOfBirth, type: String
    field :rdaGr2_placeOfDeath, type: String
    field :skos_altLabel, type: String
    field :skos_prefLabel, type: String
    field :skos_note, type: String
    field :foaf_mbox, type: String
    field :foaf_name, type: String

    delegate :edm_provider, to: :dc_contributor_agent_for, allow_nil: true

    excludes_from_rdf_output RDF::Vocab::FOAF.name, if: :for_dc_contributor_agent?
    excludes_from_rdf_output RDF::Vocab::FOAF.mbox
    # TODO: only if for dc:contributor or dc:creator, implied to be agents,
    #   e.g. not for dc:subject
    is_rdf_literal_if_blank_without RDF::Vocab::SKOS.prefLabel, RDF::Vocab::FOAF.name

    def rdf_uri
      @rdf_uri ||= edm_provided_cho.nil? ? super : edm_provided_cho.rdf_uri + '#agent-' + uuid
    end

    def edm_provided_cho
      @edm_provided_cho ||= begin
        if !dc_contributor_agent_for.nil?
          dc_contributor_agent_for
        elsif !dc_subject_agent_for.nil?
          dc_subject_agent_for
        elsif !dc_creator_agent_for_edm_web_resource&.edm_isShownBy_for&.edm_aggregatedCHO.nil?
          # TODO: update to work for web resources which are an edm:hasView too
          dc_creator_agent_for_edm_web_resource.edm_isShownBy_for.edm_aggregatedCHO
        end
      end
    end

    def dc_subject_agent_for
      @dc_subject_agent_for ||= EDM::ProvidedCHO.where(dc_subject_agent_ids: { '$in': [id] })&.first
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
