# frozen_string_literal: true

module OAI
  module Provider
   module Response
     # Override some presumptive +OAI::Provider::Response::RecordResponse+ methods
     class RecordResponse
        def identifier_for(record)
          "#{provider.prefix}/#{record.oai_pmh_record_id}"
        end

        def deleted?(record)
          !record.published?
        end
      end
    end
  end
end

# TODO: OAI-PMH resumption tokens from UUID
module Europeana
  module Contribute
    module OAI
      class Model < ::OAI::Provider::Model
        class << self
          def sets
            Campaign.all.map(&:oai_pmh_set)
          end
        end

        delegate :sets, to: :class

        def earliest
          scope.min(:first_published_at) || Time.zone.now
        end

        def latest
          scope.max(:first_published_at) || Time.zone.now
        end

        def find(selector, options = {})
          if selector == :all
            find_scope(options).all
          else
            find_scope(options).find_by(oai_pmh_record_id: selector)
          end
        end

        private

        def find_scope(options = {})
          fs = scope
          if options[:from]
            fs = fs.where(first_published_at: { '$gte': options[:from] })
          end
          if options[:until]
            fs = fs.where(first_published_at: { '$lte': options[:until] })
          end
          if options[:set]
            campaign = Campaign.find_by(dc_identifier: options[:set])
            fs = fs.where(campaign_id: campaign.id)
          end
          fs
        end

        # Scoped contributions for inclusion in OAI-PMH output
        #
        # The scope includes contributions that have ever been published, i.e.
        # those that *are* published but also those that have since been deleted,
        # for inclusion in OAI-PMH responses as deleted records.
        #
        # @return [Mongoid::Criteria] scoped contributions
        # TODO: move into a scope on +Contribution+, e.g. +.ever_published+
        def scope
          Contribution.where(first_published_at: { '$exists': true })
        end
      end
    end
  end
end
