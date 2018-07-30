# frozen_string_literal: true

namespace :contributions do
  desc 'Rerun serialisations for all published content'
  task serialise: :environment do
    count = 0
    Contribution.published.select do |contribution|
      SerialisationJob.perform_later(contribution.id.to_s)
      count += 1
    end
    puts "Enqueued #{count} contributions to be serialised."
  end
end
