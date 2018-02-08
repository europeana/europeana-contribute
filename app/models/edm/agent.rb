# frozen_string_literal: true

module EDM
  class Agent
    include Mongoid::Document
    include Mongoid::Timestamps
    include AutocompletableModel
    include Blankness::Mongoid
    include CampaignValidatableModel
    include RDFModel

    has_one :dc_creator_agent_for_edm_web_resource,
            class_name: 'EDM::ProvidedCHO', inverse_of: :dc_creator_agent,
            dependent: :nullify
    has_one :dc_contributor_agent_for,
            class_name: 'EDM::ProvidedCHO', inverse_of: :dc_contributor_agent,
            dependent: :nullify
    has_one :dc_subject_agent_for,
            class_name: 'EDM::ProvidedCHO', inverse_of: :dc_subject_agents,
            dependent: :nullify

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
