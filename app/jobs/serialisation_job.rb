# frozen_string_literal: true

class SerialisationJob < ApplicationJob
  queue_as :serialisations

  def perform(contribution_id)
    contribution = Contribution.find(contribution_id)
    serialisation = contribution.serialisations.rdfxml.first
    serialisation ||= Serialisation.new(format: 'rdfxml', contribution: contribution)
    serialisation.data = contribution.ore_aggregation.to_rdfxml
    serialisation.save!
  end
end
