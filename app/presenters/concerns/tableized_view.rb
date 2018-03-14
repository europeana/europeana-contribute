# frozen_string_literal: true

##
# Helpers for presenters working with HTML tables in the styleguide
module TableizedView
  extend ActiveSupport::Concern

  def table_cell(content, **options)
    { content: content }.merge(options).reverse_merge(row_link: true)
  end
end
