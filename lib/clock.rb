# frozen_string_literal: true

require File.expand_path('../../config/environment', __FILE__)
require 'clockwork'

include Clockwork

unless ENV['DISABLE_SCHEDULED_JOBS']
  every(1.hour, 'tmp_cleanup') do
    TmpCleanupJob.perform_later
  end
end