# frozen_string_literal: true

module Migration
  class Index < ApplicationPresenter
    def content
      mustache[:content] ||= begin
        {
          channel_info: {
            name: page_content_heading
          },
          title: page_content_heading,
          hero: {
            url:                     asset_path('migration-index-hero.jpg'),
            title:                   t('hero.title'),
            subtitle:                t('hero.subtitle'),
            attribution_title:       t('hero.attribution_text'),
            attribution_url:         hero_attribution_url,
            attribution_institution: t('hero.attribution_institution'),
            license_CC_BY_SA:        true
          },
          description: t('description'),
          begin_link: {
            url: new_migration_path,
            text: t('begin_link.text'),
            text_long: t('begin_link.text_long')
          },
          previews: [
            preview_data(1, url: 'https://www.europeana.eu/portal/record/2022608/FBIB_FBib_07004_073.html'),
            preview_data(2, url: 'https://www.europeana.eu/portal/record/2021609/objecten_60411_A_B.html'),
            preview_data(3, is_person: true),
            preview_data(4, button_opens_form: false, button_text: t('preview_4.button_text'), url: 'https://www.europeana.eu/portal/collections/migration/collection-days.html', caption_url: hero_attribution_url)
          ]
        }
      end
    end

    def preview_data(index, **opts)
      {
        button_opens_form: true,
        caption: t("preview_#{index}.caption"),
        img_url: asset_path("migration-index-preview-#{index}.jpg"),
        is_person: false,
        text: t("preview_#{index}.text"),
        url: false
      }.merge(opts)
    end

    def hero_attribution_url
      'https://www.europeana.eu/portal/record/2021641/publiek_detail_aspx_xmldescid_121074571.html'
    end

    def include_nav_searchbar
      false
    end

    def page_content_heading
      t('title')
    end

    protected

    def t(*args, **options)
      I18n.t(*args, options.reverse_merge(scope: 'contribute.campaigns.migration.pages.index'))
    end
  end
end
