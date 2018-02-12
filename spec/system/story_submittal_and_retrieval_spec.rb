# frozen_string_literal: true

require 'sidekiq/testing'

RSpec.describe 'story submittal and retrieval', sidekiq: true do

  it 'takes a submission and generates thumbnails', type: :system, js: true do
    visit new_migration_url

    fill_in('Your name', with: 'Tester One')
    fill_in('Public display name', with: 'Tester Public')
    fill_in('Your email address', with: 'tester@europeana.eu')
    fill_in('Give your story a title', with: 'Test Story')
    fill_in('Tell or describe your story', with: 'Test test test.')
    attach_file('Object 1', Rails.root + 'spec/support/media/image.jpg')

    # TODO: fix the JS errors here, so JS error checking doesn't have to be disabled
    page.driver.browser.js_errors = false

    find('input[name="commit"]').click
    expect(page).to have_content('Thank you for sharing your story!')

    #find the submission
    aggregation = ORE::Aggregation.last
    aggregatedCHO = aggregation.edm_aggregatedCHO
    expect(aggregatedCHO.dc_title).to include('Test Story')
    expect(aggregatedCHO.dc_description).to include('Test test test.')
    expect(aggregatedCHO.edm_type).to eq('IMAGE')

    # Ensure all thumbnailJobs have finished
    (1..1000).each do |i|
     break if sidekiq_log.match?(/ThumbnailJob.*INFO: done/)
    end

    webresource = aggregation.edm_isShownBy
    #check for thumbnails
    [:thumb_200x200, :thumb_400x400].each do |thumb|
      thumbnail_url =  webresource.media.url(thumb)
      thumbnail_content_type = MIME::Types.type_for(thumbnail_url).first.try(:content_type)
      expect(thumbnail_content_type).to eq('image/jpeg')
    end
  end
end