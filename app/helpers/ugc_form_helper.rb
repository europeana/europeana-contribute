# frozen_string_literal: true

# Helper module for common html atributes or other repetitve code
# that is used when generating the ugc form(s)
module UGCFormHelper
  def date_format_fallback_attributes
    { pattern: '\d{4}-\d{2}-\d{2}', placeholder: 'YYYY-MM-DD' }
  end
end
