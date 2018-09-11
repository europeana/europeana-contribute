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
          description: t('description') + video_embed_iframe,
          begin_link: {
            url: new_migration_path,
            text: t('begin_link.text'),
            text_long: t('begin_link.text_long')
          },
          previews: [
            preview_data(1, caption: nil,
                            url: 'https://www.europeana.eu/portal/search?q=europeana_collectionName%3A2084002%2A'),
            preview_data(2, caption_url: hero_attribution_url,
                            url: 'https://www.europeana.eu/portal/collections/migration/collection-days.html')
          ]
        }
      end
    end

    def preview_data(index, **opts)
      i18n_scope = "contribute.campaigns.migration.pages.index.preview_#{index}"
      {
        button_text: t(:button_text, scope: i18n_scope),
        caption: t(:caption, scope: i18n_scope),
        img_url: asset_path("migration-index-preview-#{index}.jpg"),
        is_person: false,
        text: t(:text, scope: i18n_scope),
        url: false
      }.merge(opts)
    end

    def include_nav_searchbar
      false
    end

    def page_content_heading
      t('title')
    end

    protected

    def video_embed_iframe
      view.content_tag('iframe', nil,
                       width: 560, height: 315, frameborder: 0, allow: 'autoplay; encrypted-media',
                       src: 'https://www.youtube.com/embed/I2E0GJycWOc', allowfullscreen: true)
    end

    def hero_attribution_url
      'https://www.europeana.eu/portal/record/2021641/publiek_detail_aspx_xmldescid_121074571.html'
    end

    def t(*args, **options)
      I18n.t(*args, options.reverse_merge(scope: 'contribute.campaigns.migration.pages.index'))
    end
  end
end
