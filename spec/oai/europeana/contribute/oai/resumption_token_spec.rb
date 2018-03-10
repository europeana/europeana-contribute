# frozen_string_literal: true

RSpec.describe Europeana::Contribute::OAI::ResumptionToken do
  describe '.parse' do
    let(:last_time) { '2018-03-08T11:42:51.589+00:00' }
    let(:last_uuid) { 'c1dd9b90-04f3-0136-b4a0-7824afbb2f37' }
    let(:parts) {
      {
        prefix: 'oai_edm',
        last: "#{last_time}/#{last_uuid}",
        set: 'migration',
        from: '2018-03-08T08:37:30Z',
        until: '2018-03-12T08:37:30Z'
      }
    }

    subject { described_class.parse(token_string) }

    variations = [
      %i(prefix last),
      %i(prefix last set),
      %i(prefix last from),
      %i(prefix last until),
      %i(prefix last set from),
      %i(prefix last set until),
      %i(prefix last from until),
      %i(prefix last set from until)
    ]

    variations.each do |var|
      context "with: #{var.to_sentence}" do
        let(:token_string) {
          ts = "#{parts[:prefix]}:#{parts[:last]}"
          ts = ts + ";set=#{parts[:set]}" if var.include?(:set)
          ts = ts + ";from=#{parts[:from]}" if var.include?(:from)
          ts = ts + ";until=#{parts[:until]}" if var.include?(:until)
          ts
        }

        it { is_expected.to be_a(described_class) }

        var.each do |part|
          it "extracts #{part}" do
            expect(subject.send(part)).to eq(parts[part])
          end
        end
      end
    end
  end
end
