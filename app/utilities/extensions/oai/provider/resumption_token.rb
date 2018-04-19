# frozen_string_literal: true

require 'oai/provider/resumption_token'

module OAI
  module Provider
    # OAI-PMH resumption token customisations for our own format.
    #
    # Token strings have the format:
    #   %{metadataPrefix}:%{last},set:%{set},from:%{from},until:%{until}
    #
    # +%{metadataPrefix}:%{last}+ is required. All other elements are optional,
    # and un-ordered.
    #
    # +%{last}+ will be a contribution's +#oai_pmh_resumption_token+.
    #
    # @example required parts
    #   "oai_edm:2018-03-08T11:42:51Z/c1dd9b90-04f3-0136-b4a0-7824afbb2f37"
    # @example required and optional parts
    #   "oai_edm:2018-03-08T11:42:51Z/c1dd9b90-04f3-0136-b4a0-7824afbb2f37,set:migration,from:2018-03-08T08:37:30Z,until:2018-03-12T08:37:30Z"
    class ResumptionToken
      class << self
        # Construct a resumption token instance from a token string
        #
        # @param token_string [String] token string from the request
        # @return [Europeana::Contribute::OAI::ResumptionToken] parsed token
        # @raise [OAI::ResumptionTokenException] on invalid optional parameters
        def parse(token_string)
          options = {}
          matches = token_string.match(/\A([^:]+):([^,]+)(.*)\z/)
          fail ::OAI::ResumptionTokenException.new unless matches.present? && matches[1].present? && matches[2].present?
          options[:metadata_prefix] = matches[1]
          options[:last] = matches[2]

          options.merge!(extract_optional_parameters(matches[3]))

          new(options)
        end

        def extract_optional_parameters(token_substring)
          return {} if token_substring.blank?

          token_substring.split(',').reject(&:blank?).each_with_object({}) do |optional, memo|
            optional_parts = optional.match(/\A([^:]+):(.+)\z/)

            param_name = optional_parts[1]
            fail ::OAI::ResumptionTokenException.new unless %w(set from until).include?(param_name)

            param_value = optional_parts[2]
            param_value = Time.iso8601(param_value) if %w(from until).include?(param_name)

            memo[param_name.to_sym] = param_value
          end
        end

        def extract_format(token_string)
          token_string.split(':').first
        end
      end

      def to_s
        encode_conditions
      end

      private

      def encode_conditions
        encoded_token = @prefix.to_s + ':' + last.to_s
        encoded_token << ",set:#{set}" if set
        encoded_token << ",from:#{from.utc.xmlschema}" if from
        encoded_token << ",until:#{self.until.utc.xmlschema}" if self.until
      end
    end
  end
end
