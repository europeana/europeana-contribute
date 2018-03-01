# frozen_string_literal: true

RSpec.shared_context 'migration campaign' do
  before(:each) do
    create(:cc_license, rdf_about: 'http://creativecommons.org/licenses/by-sa/4.0/')
  end
end
