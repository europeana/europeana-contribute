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

    context 'when type is a Class' do
      let(:type) { Date }

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
              expected = [Date.parse('2014-01-01'), Date.parse('2014-01-02')]
              expect(subject.mongoize(incoming)).to eq(expected)
            end
          end

          context 'with a single value' do
            it 'is a single typed value' do
              incoming = '2014-01-01'
              expected = Date.parse('2014-01-01')
              expect(subject.mongoize(incoming)).to eq(expected)
            end
          end
        end

        describe '#demongoize' do
          context 'with an array' do
            it 'is a plain array of typed elements' do
              incoming = [Date.parse('2014-01-01').mongoize, Date.parse('2014-01-02').mongoize] # i.e. instances of +Time+
              expected = [Date.parse('2014-01-01'), Date.parse('2014-01-02')]
              expect(subject.demongoize(incoming)).to eq(expected)
            end
          end

          context 'with a single value' do
            it 'is a single typed value' do
              incoming = Date.parse('2014-01-01').mongoize # i.e. instance of +Time+
              expected = Date.parse('2014-01-01')
              expect(subject.demongoize(incoming)).to eq(expected)
            end
          end
        end
      end

      context 'with a namespace' do
        let(:type) { RDF::URI }

        it 'does not fail' do
          expect { subject }.not_to raise_exception
        end

        it 'declares a namespaced class' do
          expect(subject.to_s).to eq("ArrayOf::#{type}")
        end

        it 'declares parent modules' do
          expect(described_class.const_get(type.to_s.split('::').first, false)).
            to be_a(Module)
        end
      end
    end
  end
end
