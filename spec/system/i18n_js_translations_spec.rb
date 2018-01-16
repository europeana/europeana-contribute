# frozen_string_literal: true

RSpec.describe 'I18n-js Translations' do

  it 'has I18n translations available in javascript', js: true do
    visit migration_index_url

    sleep 2
    javascript_translated = evaluate_script("I18n.translate('site.browse.newcontent.description');")
    expect(javascript_translated).to eq(I18n.translate('site.browse.newcontent.description'))
  end
end