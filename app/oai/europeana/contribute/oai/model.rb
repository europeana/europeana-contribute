# frozen_string_literal: true

# TODO: OAI-PMH resumption tokens from UUID
module Europeana
  module Contribute
    module OAI
      class Model < ::OAI::Provider::Model
        class << self
          # TODO: fix for static edm:provider
          def sets
            ORE::Aggregation.distinct(:edm_provider).map do |edm_provider|
              ::OAI::Set.new(name: edm_provider, spec: %(Europeana Contribute:#{edm_provider}))
            end
          end
        end

        delegate :sets, to: :class

        def earliest
          scope.min(:updated_at)
        end

        def latest
          scope.max(:updated_at)
        end

        def find(selector, _options = {})
          if selector == :all
            scope.all
          else
            scope.find(selector)
          end
        end

        private

        # Scoped contributions for inclusion in OAI-PMH output
        #
        # The scope includes contributions that have ever been published, i.e.
        # those that *are* published but also those that have since been deleted,
        # for inclusion in OAI-PMH responses as deleted records.
        #
        # @return [Mongoid::Criteria] scoped contributions
        def scope
          Contribution.where(first_published_at: { '$exists': true })
        end
      end
    end
  end
end
