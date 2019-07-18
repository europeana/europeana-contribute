# frozen_string_literal: true

module EuropeAtWork
# frozen_string_literal: true
  class New < ApplicationPresenter
    include FormifiedView
    include HerofiedView

    def page_hero_url
      asset_path('europe-at-work-new-hero.jpg')
    end

    def page_content_subheading
      t('contribute.campaigns.europe-at-work.pages.new.subtitle')
    end

    def page_content_heading
      t('contribute.campaigns.europe-at-work.pages.new.title')
    end
  end
end

