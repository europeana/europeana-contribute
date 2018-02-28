# frozen_string_literal: true

RSpec::Matchers.define :negotiate_content_type do |expected|
  match do |actual|
    actual.content_type == expected
  end
  failure_message do |actual|
    "expected to have negotiated content to #{expected}, but was #{actual.content_type}"
  end
end
