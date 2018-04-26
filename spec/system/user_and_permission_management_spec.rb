# frozen_string_literal: true

# These tests make use of the whole stack. For user and permissions test
# sidekiq and redis are excluded, since these are not relevant.

require 'support/shared_contexts/campaigns/migration'

RSpec.describe 'User and Permission management' do
  include_context 'migration campaign'

  let(:admin_user) { create(:user)}
  let(:event_user_email) { 'event_user@example.org' }
  let(:event_user_password) { 'fake_password'}
  let(:temp_event) { create(:edm_event) }
  let(:provided_cho) { create(:edm_provided_cho, edm_wasPresentAt: temp_event)}
  let(:aggregation)  { create(:ore_aggregation, edm_aggregatedCHO: provided_cho) }
  let(:contribution) { create(:contribution, ore_aggregation: aggregation)}
  let(:other_contribution) { create(:contribution) }

  before do
    temp_event # initialize event
    contribution # initialize contribution
  end

  it 'allows authorized users access to relevant contributions, but prohibits access after permissions were revoked', type: :system, js: true do
    # login as an administrator
    visit new_user_session_path
    fill_in('user_email', with: admin_user.email)
    fill_in('user_password', with: admin_user.password)
    find('input[name="commit"]').click

    # create a new user + assign permissions to event
    visit users_path
    click_on 'Add a new user'

    fill_in('user_email', with: event_user_email)
    fill_in('user_password', with: event_user_password)
    fill_in('user_password_confirmation', with: event_user_password)
    find(:select, 'user_role').find(:option, 'events').select_option
    find(:css, "#user_event_ids_#{ temp_event.id}[value='#{temp_event.id}']").set(true)


    find('input[name="commit"]').click

    # log out admin
    visit destroy_user_session_path

    # log in as user
    visit new_user_session_path
    fill_in('user_email', with: event_user_email)
    fill_in('user_password', with: event_user_password)
    find('input[name="commit"]').click

    # access contributions index
    visit contributions_url
    expect(page).to have_link(nil, href: edit_contribution_path(contribution))
    expect(page).to have_content(contribution.created_at)
    expect(page).to_not have_link(nil, href: edit_contribution_path(other_contribution))
    expect(page).to_not have_content(other_contribution.created_at)

    # log out user
    visit destroy_user_session_path

    # log in admin
    visit new_user_session_path
    fill_in('user_email', with: admin_user.email)
    fill_in('user_password', with: admin_user.password)
    find('input[name="commit"]').click


    # revoke users permissions
    visit users_url
    click_on event_user_email
    find(:css, "#user_event_ids_#{ temp_event.id}[value='#{temp_event.id}']").set(false)
    find('input[name="commit"]').click

    # log out admin
    visit destroy_user_session_path


    # log in user
    visit new_user_session_path
    fill_in('user_email', with: event_user_email)
    fill_in('user_password', with: event_user_password)
    find('input[name="commit"]').click

    # be unable to access contributions index
    visit contributions_url
    expect(page).to have_content('Forbidden')
  end
end