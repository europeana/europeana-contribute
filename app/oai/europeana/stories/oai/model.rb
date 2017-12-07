# frozen_string_literal: true

# TODO: OAI-PMH resumption tokens
module Europeana
  module Stories
    module OAI
      class Model < ::OAI::Provider::Model
        def earliest
          ORE::Aggregation.min(:updated_at)
        end

        def latest
          ORE::Aggregation.max(:updated_at)
        end

        def find(selector, _options = {})
          if selector == :all
            ORE::Aggregation.all
          else
            ORE::Aggregation.find(selector)
          end
        end

        def sets
          ORE::Aggregation.distinct(:edm_provider).map do |edm_provider|
            ::OAI::Set.new(name: edm_provider, spec: edm_provider)
          end
        end
      end
    end
  end
end
