# frozen_string_literal: true

require 'support/shared_contexts/campaigns/europe-at-work'
require 'support/shared_examples/controllers/contributable'

RSpec.describe EuropeAtWorkController do
  include_context 'europe-at-work campaign'

  let(:campaign) { Campaign.find_by(dc_identifier: 'europe-at-work') }

  it_behaves_like 'a Contributable controller'
end
