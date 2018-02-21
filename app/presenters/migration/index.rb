# frozen_string_literal: true

module Migration
  class Index < ApplicationPresenter
    def content
      mustache[:content] ||= begin
        {
          title: page_content_heading,
          hero: {
            url:              '/images/channel_hero_migrations.jpg',
            title:            'Why contribute with your story?',
            subtitle:         'We all have objects to share and stories to tell about where we\'ve come from and what\'s shaped our lives.  For many of us, that involves our family\'s stories of migration and immigration.',
            attribution_text: 'This is a placeholder image found somewhere',
            attribution_url:  'http://www.europeana.eu/portal/record/2048211/449.html',
            license_public:   true
          },
          description: 'Sharing your own personal migration history can help us to tell a really big story - the story of Europe and the people who live here. We invite you to <strong>share your story</strong> - through objects like pictures, letters, postcards or recipes - with <strong>Europeana Migration</strong> at one of our collection days or by visiting our website.',
          title: false,
          closing_remark: 'Closing remark to emphasise the importance of sharing... may not be needed',

          begin_link: {
            url: new_migration_path,
            text: t('begin_link'),
            text_long: 'share your story'
          },
          call_to_action: 'We invite you to contribute stories relating to European migration in your family history.',
          previews: [
            {
              caption: 'Pocket watch | Cloesen, Barent van der. Rijksmuseum. Public Domain',
              img_url: '/images/ugc-preview-1.jpg',
              is_person: false,
              text: 'These objects are important parts of your heritage and recording and digitising them is easier than you might think. Once it’s done, they will become part of the Europeana Migration Collection.',
              url: 'javascript:alert("follow link to preview")'
            },
            {
              caption: 'Avfotografert postkort som ble sendt fra emigrerte vadsøværinger i USA til slekt og venner i Norge. Finnmark Fylkesbibliotek. Public Domain',
              img_url: '/images/ugc-preview-2.jpg',
              is_person: false,
              text: 'Your story is part of Europe\’s rich and shared history of migration, and now it can be recorded for the future, and made freely available for anyone to discover and use for education, research, inspiration and pleasure.',
              url: 'javascript:alert("follow link to preview")'
            },
            {
              button_text: 'Read more about Marijke\'s story',
              caption: 'Marijke\'s Photo | Europeana.  Public Domain',
              img_url: '/images/ugc-preview-3.jpg',
              is_person: true,
              text: 'For an international day at my school in Senegal when I was about 6, my mother dressed my brother like the Ghanian flag - she was from Ghana - and me like the Dutch flag - my father is Dutch',
              url: 'javascript:alert("follow link to preview")'
            }
          ]
        }
      end
    end

    def include_nav_searchbar
      true
    end

    def call_to_action
      t('call_to_action')
    end

    def page_content_heading
      t('title')
    end

    protected

    def t(*args, **options)
      I18n.t(*args, options.reverse_merge(scope: 'site.campaigns.migration.pages.index'))
    end
  end
end
