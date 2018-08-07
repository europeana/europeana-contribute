# frozen_string_literal: true

require 'support/shared_contexts/campaigns/migration'

RSpec.describe 'I18n-js Translations' do
  include_context 'migration campaign'

  it 'has I18n translations available in javascript', type: :system, js: true do
    visit new_migration_url

    sleep 2
    javascript_translated = evaluate_script("I18n.translate('site.browse.newcontent.description');")
    expect(javascript_translated).to eq(I18n.translate('site.browse.newcontent.description'))
  end
end
