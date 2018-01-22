# frozen_string_literal: true

module EDM
  class Agent
    include Mongoid::Document
    include AutocompletableModel
    include CampaignValidatableModel
    include RDFModel
    include RemoveBlankAttributes

    embedded_in :dc_creator_for_edm_providedCHO, class_name: 'EDM::ProvidedCHO', inverse_of: :dc_creator
    embedded_in :dc_creator_for_edm_webResource, class_name: 'EDM::ProvidedCHO', inverse_of: :dc_creator
    embedded_in :dc_contributor_for, class_name: 'EDM::ProvidedCHO', inverse_of: :dc_contributor
    embedded_in :dc_subject_agents_for, class_name: 'EDM::ProvidedCHO', inverse_of: :dc_subject_agents

    field :rdaGr2_dateOfBirth, type: Date
    field :rdaGr2_dateOfDeath, type: Date
    field :rdaGr2_placeOfBirth, type: String
    field :rdaGr2_placeOfDeath, type: String
    field :skos_altLabel, localize: true
    field :skos_prefLabel, localize: true
    field :skos_note, localize: true
    field :foaf_mbox, type: String
    field :foaf_name, type: String

    delegate :edm_provider, to: :dc_contributor_for, allow_nil: true

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

    def blank?
      attributes.except('_id').values.all?(&:blank?)
    end
  end
end
