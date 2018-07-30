# frozen_string_literal: true

namespace :serialisations do
  desc 'Rerun serialisations for all published content'
  task rerun: :environment do
    count = 0
    Contribution.published.select do |contribution|
      SerialisationJob.perform_later(contribution.id.to_s)
      count += 1
    end
    puts "Enqueued #{count} contributions to be re-serialised."
  end
end
