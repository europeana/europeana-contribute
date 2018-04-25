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

  before do
    temp_event # initialize event
  end

  it 'allows authorized users access to relevant contributions, but prohibits access after permissions were revoked', type: :system, js: true do
    # login as an administrator
    visit login_url
    fill_in('user_email', with: admin_user.email)
    fill_in('user_password', with: admin_user.password)
    find('input[name="commit"]').click

    # create a new user + assign permissions to event
    visit users_index_url
    click 'add user'

    fill_in('user_email', with: event_user_email)
    fill_in('user_password', with: event_user_password)
    fill_in('user_password_confirmation', with: event_user_password)
    fill_in('user_role', with: 'events')
    select('user_event[0]', temp_event.id)

    find('input[name="_save"]').click

    # log out admin
    visist 'users/sign_out'

    # log in as user
    visit login_url
    fill_in('user_email', with: event_user_email)
    fill_in('user_password', with: event_user_password)
    find('input[name="commit"]').click

    # access contributions index
    visit contributions_url
    expect(page).to contain(contribution.title)
    expect(page).to contain(contribution.ticket_number)
    expect(page).to contain(contribution.aasm_state)
    expect(page).to_not contain(other_contribution.title)
    expect(page).to_not contain(other_contribution.ticket_number)
    expect(page).to_not contain(other_contribution.aasm_state)

    # log out user
    visist 'users/sign_out'

    # log in admin
    visit login_url
    fill_in('user_email', with: admin_user.email)
    fill_in('user_password', with: admin_user.password)
    find('input[name="commit"]').click

    # revoke users permissions
    visit users_index_url
    click event_user_email
    click remove_event
    find('input[name="commit"]').click

    # log out admin
    visist 'users/sign_out'

    # log in user
    visit login_url
    fill_in('user_email', with: event_user_email)
    fill_in('user_password', with: event_user_password)
    find('input[name="commit"]').click

    # be unable to access contributions index
    visit contributions_url
    expect(URI.parse(page.current_url).path).to eq(URI.parse(new_migration_url).path)
  end
end