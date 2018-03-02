# frozen_string_literal: true

# TODO: OAI-PMH resumption tokens
module Europeana
  module Contribute
    module OAI
      class Model < ::OAI::Provider::Model
        class << self
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

        def scope
          Contribution.published
        end
      end
    end
  end
end
