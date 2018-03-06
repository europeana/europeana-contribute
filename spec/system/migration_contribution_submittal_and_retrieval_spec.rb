# frozen_string_literal: true

# These tests make use of the whole stack including redis through sidekiq.
# In order to properly adapt/inspect jobs/data queued/generated by sidekiq,
# 'sidekiq/testing' and 'sidekiq/api' need to be included.
require 'sidekiq/testing'
require 'sidekiq/api'

require 'support/shared_contexts/campaigns/migration'

RSpec.describe 'Migration contribution submittal and retrieval', sidekiq: true do
  include_context 'migration campaign'

  before do
    # TODO: When form saving is fully functional consider enabling it here
    ENV['ENABLE_JS_FORM_SAVE'] = 'false'
  end

  it 'takes a submission and generates thumbnails', type: :system, js: true do
    existing_aggregation = ORE::Aggregation.last

    visit new_migration_url

    sleep 2

    # Omit required data and submit
    initial_input = {
      'Your name' => 'Tester One',
      'Public display name' => 'Tester Public',
      'Your email address' => 'tester@europeana.eu',
      'Give your story a title' => 'Test Contribution',
      'Tell or describe your story' => 'Test test test.'
    }
    initial_input.each_pair do |locator, value|
      fill_in(locator, with: value)
    end
    check('I am over 16 years old')
    check('contribution_content_policy_accept')
    check('contribution_display_and_takedown_accept')
    attach_file('Object 1', Rails.root + 'spec/support/media/image.jpg')
    find('input[name="commit"]').click

    # Check that the form re-renders pre-populated
    expect(page).not_to have_content(I18n.t('contribute.campaigns.migration.pages.create.flash.success'))
    initial_input.each_pair do |locator, value|
      expect(find_field(locator, with: value)).not_to be_nil
    end

    # Fill in missing data and re-submit
    fill_in('Enter a name', with: 'Dr Subject Agent Name')
    find('input[name="commit"]').click
    expect(page).to have_content(I18n.t('contribute.campaigns.migration.pages.create.flash.success'))

    # Find the submission
    aggregation = ORE::Aggregation.last

    # Make sure it's a newly created aggregation.
    expect(aggregation).to_not eq(existing_aggregation)

    # Check the CHO attributes.
    aggregatedCHO = aggregation.edm_aggregatedCHO
    expect(aggregatedCHO.dc_title).to include('Test Contribution')
    expect(aggregatedCHO.dc_description).to include('Test test test.')
    expect(aggregatedCHO.edm_type).to eq('IMAGE')

    # Check the contributor attributes.
    dc_contributor = aggregatedCHO.dc_contributor_agent
    expect(dc_contributor).not_to be_nil
    expect(dc_contributor.foaf_mbox).to include('tester@europeana.eu')

    # Ensure all thumbnailJobs have been picked up
    timeout = 20
    queue = Sidekiq::Queue.new('thumbnails')
    while queue.size.nonzero?
      sleep 1
      timeout -= 1
      fail('Waited too long to process thumbnail jobs.') if timeout.zero?
    end

    webresource = aggregation.edm_isShownBy

    # Check for thumbnails
    [200, 400].each do |dimension|
      thumb_sym = "thumb_#{dimension}x#{dimension}".to_sym
      thumbnail_url =  webresource.media.url(thumb_sym)

      # Ensure thumbnail is retrievable over http.
      timeout = 20
      response = nil
      while response&.status != 200
        sleep 1
        timeout -= 1
        response = Faraday.get(thumbnail_url)
        fail("Waited too long before thumbnail was http accessible. #{thumbnail_url}") if timeout.zero?
      end
      expect(response['content-type']).to eq('image/jpeg')

      # Check image attributes using MiniMagick
      img = MiniMagick::Image.open(thumbnail_url)
      expect(img.mime_type).to eq('image/jpeg')
      expect(img.dimensions).to eq([dimension, dimension])
    end
  end
end
