# frozen_string_literal: true

RSpec.describe DeletedResource do
  subject { create(:deleted_resource) }

  it { is_expected.to respond_to(:resource_type) }
  it { is_expected.to respond_to(:resource_identifier) }
  it { is_expected.to respond_to(:deleted_at) }

  describe 'class' do
    subject { described_class }
    it { is_expected.to include(Mongoid::Document) }
  end

  describe 'relations' do
    it {
      is_expected.to belong_to(:deleted_by).of_type(User).
        as_inverse_of(:deleted_resources).with_dependent(nil)
    }
  end

  describe 'indexes' do
    it { is_expected.to have_index_for(resource_type: 1, resource_identifier: 1) }
  end

  describe 'deleted_at attribute' do
    let(:time_now_fixed) { Time.now }
    before do
      time_now_fixed # call time_now_fixed to set a fixed time to work with.
      allow(Time).to receive(:now) { time_now_fixed }
    end

    it 'is set at creation' do
      expect(subject.deleted_at).to eq(time_now_fixed)
    end
  end
end
