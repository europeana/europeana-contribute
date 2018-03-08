# frozen_string_literal: true

RSpec.shared_context 'migration campaign' do
  before(:each) do
    create(:cc_license, rdf_about: 'http://creativecommons.org/publicdomain/mark/1.0/')
    create(:cc_license, rdf_about: 'http://creativecommons.org/licenses/by-sa/4.0/')
    create(:cc_license, rdf_about: 'http://rightsstatements.org/vocab/CNE/1.0/')
    create(:campaign, dc_identifier: 'migration', dc_subject: 'http://data.europeana.eu/concept/base/128')
  end
end
