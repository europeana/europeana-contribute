# frozen_string_literal: true

RSpec.describe ArrayOf do
  describe '.type' do
    subject { ArrayOf.type(type) }

    context 'when type is not a Class' do
      let(:type) { 'not a class' }

      it 'fails' do
        expect { subject }.to raise_exception(ArgumentError)
      end
    end

    it 'handles namespaced classes'
    # e.g. RDF::URI

    context 'when type is a Class' do
      let(:type) { DateTime }

      it 'does not fail' do
        expect { subject }.not_to raise_exception
      end

      it 'declares a namespaced class' do
        expect(subject.to_s).to eq("ArrayOf::#{type}")
      end

      describe 'declared class' do
        it 'subclasses Array' do
          expect(subject.superclass).to eq(Array)
        end

        it 'registers element type' do
          expect(subject.element_type).to eq(type)
        end

        describe '#mongoize' do
          context 'with an array' do
            it 'is a plain array of typed elements' do
              incoming = ['2014-01-01', '2014-01-02']
              expected = [DateTime.parse('2014-01-01'), DateTime.parse('2014-01-02')]
              expect(subject.mongoize(incoming)).to eq(expected)
            end
          end

          context 'with a single value' do
            it 'is a single typed value' do
              incoming = '2014-01-01'
              expected = DateTime.parse('2014-01-01')
              expect(subject.mongoize(incoming)).to eq(expected)
            end
          end
        end
      end
    end
  end
end
