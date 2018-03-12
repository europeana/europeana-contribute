# frozen_string_literal: true

RSpec.shared_examples 'blankness check' do |meth|
  describe '.blankness_checkers' do
    it "includes #{meth.inspect} in checkers" do
      expect(subject.class.blankness_checkers).to include(meth)
    end
  end

  describe '#blank?' do
    it "calls #{meth.inspect}" do
      expect(subject).to receive(meth)
      subject.blank?
    end
  end
end
