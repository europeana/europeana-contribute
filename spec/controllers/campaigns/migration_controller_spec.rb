# frozen_string_literal: true

require 'support/shared_contexts/campaigns/migration'
require 'support/shared_examples/controllers/contributable'

RSpec.describe Campaigns::MigrationController do
  include_context 'migration campaign'

  let(:campaign) { Campaign.find_by(dc_identifier: 'migration') }

  it_behaves_like 'a Contributable controller'
end
