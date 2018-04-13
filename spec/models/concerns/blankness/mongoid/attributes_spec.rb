# frozen_string_literal: true

RSpec.describe Blankness::Mongoid::Attributes do
  before(:all) do
    class Fish
      include Mongoid::Document
      include Blankness::Mongoid::Attributes
      field :name, type: String
      field :food, type: Array, default: []
    end
  end

  after(:all) do
    Object.send(:remove_const, :Fish)
  end

  context 'when field has default' do
    it 'removes it' do
      fish = Fish.new(food: ['plants'])
      fish.save
      fish.reload
      fish.food = ['']
      fish.save
      expect(fish.reload.food).to eq([])
    end
  end

  context 'when field has no default' do
    it 'removes it' do
      fish = Fish.new(name: 'Jonah')
      fish.save
      fish.reload
      fish.name = ''
      fish.save
      expect(fish.reload.name).to eq(nil)
    end
  end
end
