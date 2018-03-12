# frozen_string_literal: true

RSpec.describe ArrayOfAttributeValidation do
  let(:model_class) do
    Class.new do
      include Mongoid::Document
      include ArrayOfAttributeValidation
      field :dates, type: ArrayOf.type(Date)
    end
  end

  context 'when attribute value is scalar' do
    let(:attribute_value) { '2018-01-13' }
    it 'is invalid' do
      expect { model_class.new(dates: attribute_value) }.
        to raise_exception(Mongoid::Errors::InvalidValue, /ArrayOf::Date/)
    end
  end

  context 'when attribute value is Array' do
    let(:attribute_value) { ['2018-01-13'] }
    it 'is valid' do
      expect { model_class.new(dates: attribute_value) }.
        not_to raise_exception
    end
  end
end
