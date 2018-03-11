# frozen_string_literal: true

module Europeana
  module Contribute
    module OAI
      module Provider
        class Model < ::OAI::Provider::Model
          class << self
            attr_accessor :limit

            def sets
              Campaign.all.map(&:oai_pmh_set)
            end

            # Scoped contributions for inclusion in OAI-PMH output
            #
            # The scope includes contributions that have ever been published, i.e.
            # those that *are* published but also those that have since been deleted,
            # for inclusion in OAI-PMH responses as deleted records.
            #
            # Scope is ordered by +oai_pmh_resumption_token+.
            #
            # @return [Mongoid::Criteria] scoped contributions
            def scope
              Contribution.where(first_published_at: { '$exists': true }).
                           order(oai_pmh_resumption_token: 1)
            end
          end

          self.limit = 100

          delegate :scope, :sets, to: :class

          def earliest
            scope.min(:first_published_at) || Time.zone.now
          end

          def latest
            scope.max(:first_published_at) || Time.zone.now
          end

          def find(selector, options = {})
            selector == :all ? find_all(options) : find_one(selector, options)
          end

          private

          # @param selector [String] +oai_pmh_record_id+ of the contribution to find
          # @return [Contribution]
          def find_one(selector, **options)
            find_scope(options).find_by(oai_pmh_record_id: selector)
          end

          # @return [Mongoid::Criteria] if no more records are available
          # @return [OAI::Provider::PartialResult] if more records are available
          def find_all(**options)
            if options[:resumption_token]
              token = ::OAI::Provider::ResumptionToken.parse(options[:resumption_token])
              criteria = resumption_token_find_scope(token)
            else
              criteria = find_scope(options)
              token = nil
            end

            partial_result?(criteria) ? partial_result(criteria, token, options) : criteria
          end

          # @param criteria [Mongoid::Criteria]
          # @param token [OAI::Provider::ResumptionToken]
          # @return [OAI::Provider::PartialResult]
          def partial_result(criteria, token = nil, **options)
            criteria = criteria.limit(self.class.limit)
            last = criteria.offset(self.class.limit - 1).limit(1).pluck(:oai_pmh_resumption_token).first

            token ||= ::OAI::Provider::ResumptionToken.new(options)

            ::OAI::Provider::PartialResult.new(criteria, token.next(last))
          end

          # Are there more records after this batch?
          #
          # @param criteria [Mongoid::Criteria]
          def partial_result?(criteria)
            criteria.count(limit: self.class.limit + 1) > self.class.limit
          end

          # @return [Mongoid::Criteria]
          def find_scope(options = {})
            if options[:resumption_token]
              return resumption_token_find_scope(options[:resumption_token])
            end

            criteria = scope
            %i(from until set).each do |option|
              criteria = send(:"add_#{option}_criterion", criteria, options[option]) if options[option]
            end
            criteria
          end

          # @param criteria [Mongoid::Criteria]
          # @param from_option [String]
          def add_from_criterion(criteria, from_option)
            criteria.where(first_published_at: { '$gte': from_option })
          end

          # @param criteria [Mongoid::Criteria]
          # @param until_option [String]
          def add_until_criterion(criteria, until_option)
            criteria.where(first_published_at: { '$lte': until_option })
          end

          # @param criteria [Mongoid::Criteria]
          # @param set_option [String]
          def add_set_criterion(criteria, set_option)
            campaign = Campaign.find_by(dc_identifier: set_option)
            criteria.where(campaign_id: campaign.id)
          end

          # @param token [OAI::Provider::ResumptionToken]
          # @return [Mongoid::Criteria]
          def resumption_token_find_scope(token)
            resumption_options = token.to_conditions_hash
            criteria = find_scope(resumption_options)
            criteria = criteria.where(oai_pmh_resumption_token: { '$gt': token.last })
            criteria
          end
        end
      end
    end
  end
end
