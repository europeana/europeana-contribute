# frozen_string_literal: true

RSpec.describe SerialisationJob do
  it { is_expected.to be_processed_in :serialisations }

  context 'when contribution has no RDF/XML serialisation' do
    let(:contribution) { create(:contribution) }
    it 'creates one' do
      expect(contribution.serialisations.rdfxml).to be_blank
      subject.perform(contribution.id.to_s)
      expect(contribution.serialisations.rdfxml).to be_present
      expect(contribution.serialisations.rdfxml.first.data).to eq(contribution.ore_aggregation.to_rdfxml)
    end
  end

  context 'when contribution has an RDF/XML serialisation' do
    let(:contribution) { create(:contribution) }
    it 'updates it' do
      create(:serialisation, contribution: contribution)
      expect(contribution.serialisations.rdfxml).to be_present
      expect(contribution.serialisations.rdfxml.first.data).not_to eq(contribution.ore_aggregation.to_rdfxml)
      subject.perform(contribution.id.to_s)
      expect(contribution.serialisations.rdfxml).to be_present
      expect(contribution.serialisations.rdfxml.first.data).to eq(contribution.ore_aggregation.to_rdfxml)
    end
  end
end
