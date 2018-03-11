module Vocabularies
  module Europeana
    module Contribute
      class GettyAATController < VocabulariesController
        class << self
          def data
            @data ||= YAML.load_file(File.join(Rails.root, 'db', 'getty-aat-web-resource-dc-types.yml'))
          end
        end

        vocabulary_index text: 'text',
                         value: 'value'
        vocabulary_show text: 'text',
                        value: 'value'

        delegate :data, to: :class

        def index
          matches = data.select { |d| d['text'].downcase.start_with?((params[:q] || '').downcase) }
          render json: index_data(matches).uniq
        end

        def show
          match = data.detect { |d| d['value'] == show_uri.to_s }
          render json: show_data(match)
        end
      end
    end
  end
end
