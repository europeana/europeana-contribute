# frozen_string_literal: true

require 'aasm/rspec'

RSpec.describe Contribution do
  subject { create(:contribution) }

  describe 'class' do
    subject { described_class }
    it { is_expected.to include(Mongoid::Document) }
    it { is_expected.to include(Mongoid::Timestamps) }
    it { is_expected.to include(RecordableDeletion) }
    it { is_expected.to include(RDF::Dumpable) }
  end

  describe 'relations' do
    it {
      is_expected.to belong_to(:campaign).of_type(Campaign).
        as_inverse_of(:contributions).with_dependent(nil)
    }
    it {
      is_expected.to belong_to(:created_by).of_type(User).
        as_inverse_of(:contributions).with_dependent(nil)
    }
    it {
      is_expected.to belong_to(:ore_aggregation).of_type(ORE::Aggregation).
        as_inverse_of(:contribution).with_autobuild.with_dependent(:destroy)
    }
    it {
      is_expected.to have_many(:serialisations).of_type(Serialisation).
        as_inverse_of(:contribution).with_dependent(:destroy)
    }
    it { is_expected.to accept_nested_attributes_for(:ore_aggregation) }
  end

  describe 'indexes' do
    it { is_expected.to have_index_for(aasm_state: 1) }
    it { is_expected.to have_index_for(campaign: 1) }
    it { is_expected.to have_index_for(created_at: 1) }
    it { is_expected.to have_index_for(created_by: 1) }
    it { is_expected.to have_index_for(first_published_at: 1) }
    it { is_expected.to have_index_for(oai_pmh_record_id: 1) }
    it { is_expected.to have_index_for(oai_pmh_resumption_token: 1) }
    it { is_expected.to have_index_for(ore_aggregation: 1) }
    it { is_expected.to have_index_for(updated_at: 1) }
  end

  describe 'destruction' do
    subject { create(:contribution) }

    context 'when the contribution was NEVER published' do
      it 'should allow destrutction' do
        expect(subject.destroy).to eq(true)
      end
    end

    context 'when the contribution is published' do
      it 'should NOT allow destrutction' do
        subject.publish
        expect(subject.destroy).to eq(false)
      end
    end

    context 'when the contribution WAS published' do
      it 'should NOT allow destrutction' do
        subject.publish
        subject.unpublish
        expect(subject.destroy).to eq(false)
      end
    end
  end

  describe 'DeletedResource creation' do
    subject { create(:contribution) }

    context 'wiping when the contribution was published' do
      it 'should create a DeletedWebResource record' do
        subject.publish
        subject.unpublish
        id = subject.id
        # 1 for contribution + 1 for isShownBy
        expect { subject.wipe }.to(change { DeletedResource.count }.by(2))
        expect(DeletedResource.contributions.find_by(resource_identifier: id)).to_not be_nil
      end
    end

    context 'when the contribution was never published' do
      it 'should NOT create a DeletedWebResource record' do
        id = subject.id
        expect { subject.destroy }.to_not(change { DeletedResource.count })
        expect { DeletedResource.contributions.find_by(resource_identifier: id) }.to raise_error(Mongoid::Errors::DocumentNotFound)
      end
    end
  end

  it 'should autobuild ore_aggregation' do
    expect(subject.ore_aggregation).not_to be_nil
  end

  describe '#sets' do
    let(:campaign) { create(:campaign) }
    subject { create(:contribution, campaign: campaign).sets }

    it 'returns the OAI-PMH set for the campaign' do
      expect(subject).to be_a(Array)
      expect(subject.length).to eq(1)
      expect(subject.first).to be_a(OAI::Set)
      expect(subject.first.spec).to eq(campaign.dc_identifier)
    end
  end

  describe '#to_oai_edm' do
    subject { create(:contribution).to_oai_edm }

    it 'returns RDF/XML without XML instruction' do
      expect(subject).to be_a(String)
      expect(subject).to start_with('<rdf:RDF')
    end

    context 'with contributor name and email' do
      subject do
        aggregation = build(:ore_aggregation)
        aggregation.build_edm_aggregatedCHO
        aggregation.edm_aggregatedCHO.dc_contributor_agent = build(
          :edm_agent, foaf_name: ['My name'], foaf_mbox: ['me@example.org'], skos_prefLabel: 'Me'
        )
        contribution = build(:contribution)
        contribution.ore_aggregation = aggregation
        contribution.to_oai_edm
      end

      it 'removes them' do
        expect(subject).not_to include('<foaf:name>My name</foaf:name>')
        expect(subject).not_to include('<foaf:mbox>me@example.org</foaf:mbox>')
        expect(subject).to include('<dc:contributor>Me</dc:contributor>')
      end
    end
  end

  describe 'AASM' do
    it { is_expected.to have_state(:draft) }
    it { is_expected.to transition_from(:draft).to(:published).on_event(:publish) }

    context 'when it is published' do
      before { subject.publish }
      it { is_expected.to transition_from(:published).to(:draft).on_event(:unpublish) }
    end

    context 'when it was published' do
      before { subject.first_published_at = Time.zone.now }
      it { is_expected.to transition_from(:draft).to(:deleted).on_event(:wipe) }
    end

    context 'when it was NOT published' do
      it 'should prevent wiping via the guard' do
        expect { subject.wipe }.to raise_error(AASM::InvalidTransition)
      end
    end

    describe 'publish event' do
      context 'without first_published_at' do
        let(:contribution) { build(:contribution) }
        it 'sets it' do
          expect { contribution.publish }.to(change { contribution.first_published_at }.from(nil))
        end
      end

      context 'with first_published_at' do
        let(:contribution) { build(:contribution, first_published_at: Time.zone.now - 1.day) }
        it 'does not change it' do
          expect { contribution.publish }.not_to(change { contribution.first_published_at })
        end
      end

      it 'touches oai_pmh_datestamp' do
        expect { subject.publish }.to(change { subject.oai_pmh_datestamp })
      end
    end

    describe 'unpublish event' do
      let(:contribution) { create(:contribution, :published) }
      it 'touches oai_pmh_datestamp' do
        expect { contribution.unpublish }.to(change { contribution.oai_pmh_datestamp })
      end
    end
  end

  describe '#oai_pmh_record_id' do
    context 'when contribution is saved' do
      it "is set to aggregation's CHO's UUID" do
        contribution = build(:contribution, :published)
        contribution.save!
        expect(contribution.oai_pmh_record_id).to eq(contribution.ore_aggregation.edm_aggregatedCHO.uuid)
      end
    end
  end

  describe '#oai_pmh_resumption_token' do
    it 'is set when contribution is first published and saved' do
      contribution = build(:contribution, :published)
      expect { contribution.save! }.to(change { contribution.oai_pmh_resumption_token }.from(nil))
    end

    it 'joins first_published_at and oai_pmh_record_id with "/"' do
      contribution = build(:contribution, :published)
      contribution.save!
      oai_pmh_resumption_token = contribution.first_published_at.iso8601.sub(/[+-]00:00\z/, 'Z') + '/' + contribution.oai_pmh_record_id
      expect(contribution.oai_pmh_resumption_token).to eq(oai_pmh_resumption_token)
    end
  end

  context 'after save' do
    context 'when published' do
      it 'queues a serialisation job' do
        contribution = create(:contribution, :published)
        expect(ActiveJob::Base.queue_adapter).to receive(:enqueue).with(SerialisationJob)
        contribution.save
      end
    end

    context 'when draft' do
      it 'does not queue a serialisation job' do
        contribution = create(:contribution)
        expect(ActiveJob::Base.queue_adapter).not_to receive(:enqueue).with(SerialisationJob)
        contribution.save
      end
    end
  end

  describe '#to_rdfxml' do
    context 'with an RDF/XML serialisation stored' do
      it 'returns its data' do
        contribution = create(:contribution)
        serialisation = create(:serialisation, contribution: contribution)
        expect(contribution.serialisations.rdfxml).to be_present
        expect(contribution.ore_aggregation).not_to receive(:to_rdfxml)
        expect(contribution.to_rdfxml).to eq(serialisation.data)
      end
    end

    context 'without an RDF/XML serialisation stored' do
      it 'delegates to ore_aggregation' do
        contribution = create(:contribution, :published)
        expect(contribution.serialisations.rdfxml).to be_blank
        expect(contribution.to_rdfxml).to eq(contribution.ore_aggregation.to_rdfxml)
      end
    end
  end

  describe '#ever_published?' do
    context 'when first_published_at is set' do
      let(:contribution) { build(:contribution, first_published_at: Time.parse(Time.zone.now.iso8601)) }
      it 'returns true' do
        expect(contribution.ever_published?).to eq(true)
      end
    end

    context 'when first_published_at is NOT set' do
      let(:contribution) { build(:contribution) }
      it 'returns false' do
        expect(contribution.ever_published?).to eq(false)
      end
    end
  end
end
