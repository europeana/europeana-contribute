# frozen_string_literal: true

%w(
  https://creativecommons.org/licenses/by-sa/4.0
  https://creativecommons.org/licenses/by/4.0
  https://creativecommons.org/publicdomain/mark/1.0/
  https://creativecommons.org/publicdomain/zero/1.0/
).each do |license|
  CC::License.create!(rdf_about: license) unless CC::License.where(rdf_about: license).present?
end
