# frozen_string_literal: true

module Blankness
  module Mongoid
    extend ActiveSupport::Concern
    include Attributes
    include Relations
  end
end
