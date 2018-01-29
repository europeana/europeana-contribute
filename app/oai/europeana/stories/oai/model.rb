# frozen_string_literal: true

# TODO: OAI-PMH resumption tokens
module Europeana
  module Stories
    module OAI
      class Model < ::OAI::Provider::Model
        class << self
          def sets
            Story.distinct(:edm_provider).map do |edm_provider|
              ::OAI::Set.new(name: edm_provider, spec: %(Europeana Stories:#{edm_provider}))
            end
          end
        end

        delegate :sets, to: :class

        def earliest
          Story.min(:updated_at)
        end

        def latest
          Story.max(:updated_at)
        end

        def find(selector, _options = {})
          if selector == :all
            Story.all
          else
            Story.find(selector)
          end
        end
      end
    end
  end
end
