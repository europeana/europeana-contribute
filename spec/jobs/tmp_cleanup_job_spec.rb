# frozen_string_literal: true

RSpec.describe TmpCleanupJob do
  it { is_expected.to be_processed_in :tmp_cleanup }

  it 'calls MediaUploader.clean_cached_files!' do
    expect(MediaUploader).to receive(:clean_cached_files!)
    subject.perform
  end
end
