# frozen_string_literal: true

class TmpCleanupJob < ApplicationJob
  queue_as :tmp_cleanup

  ##
  # This job will remove temporary files older than 24 hours from the temporary storage used by the MediaUploader class
  #
  def perform
    MediaUploader.clean_cached_files! # This also takes an argument that defaults to 60*60*24 which is 24 hours
  end
end
