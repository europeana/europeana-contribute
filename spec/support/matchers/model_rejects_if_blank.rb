# frozen_string_literal: true

RSpec::Matchers.define :reject_if_blank do |expected|
  match do |actual|
    actual.rejectable_relations.include?(expected.to_s)
  end
end
