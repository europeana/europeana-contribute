# frozen_string_literal: true

RSpec.describe Blankness::Mongoid::Attributes do
  before(:all) do
    class Fish
      include Mongoid::Document
      include Blankness::Mongoid::Attributes
      field :food, type: Array, default: []
    end
  end

  after(:all) do
    Object.send(:remove_const, :Fish)
  end

  it 'sets blank values to field default' do
    fish = Fish.new(food: ['plants'])
    fish.save
    fish.reload
    fish.food = ['']
    fish.save
    expect(fish.reload.food).to eq([])
  end
end
