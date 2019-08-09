# frozen_string_literal: true

# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
Rails.application.routes.draw do
  devise_for :users

  root to: 'pages#show', defaults: { identifier: '/' }

  resources :media, param: :uuid, only: :show do
    member do
      get ':size', action: :show, constraints: { size: /w[24]00/ }, as: :thumbnail
    end
  end

  resources :contributions, param: :uuid, only: %i(index show edit destroy) do
    member do
      get :delete
      get :thumbnail, action: :select_thumbnail
      patch :thumbnail, action: :set_thumbnail
    end
  end

  resources :events, param: :uuid do
    member do
      get :delete
    end
  end

  resources :users, param: :id do
    member do
      get :delete
    end
  end

  scope module: :campaigns do
    resources :europe_at_work, param: :uuid, only: %i(new create edit update), path: 'europe-at-work'
    resources :migration, param: :uuid, only: %i(index new create edit update)
  end

  get 'oai', to: 'oai#index'

  get 'vocabularies/europeana/places', to: 'vocabularies/europeana/places#index'
  get 'vocabularies/europeana/places/dereference', to: 'vocabularies/europeana/places#show'
  get 'vocabularies/europeana/contribute/getty_aat', to: 'vocabularies/europeana/contribute/getty_aat#index'
  get 'vocabularies/europeana/contribute/getty_aat/dereference', to: 'vocabularies/europeana/contribute/getty_aat#show'
  get 'vocabularies/geonames', to: 'vocabularies/geonames#index'
  get 'vocabularies/unesco', to: 'vocabularies/unesco#index'
  get 'vocabularies/unesco/dereference', to: 'vocabularies/unesco#show'

  get '*identifier', to: 'pages#show', as: 'static_page'
end
