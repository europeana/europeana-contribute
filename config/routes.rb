# frozen_string_literal: true

# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
Rails.application.routes.draw do
  devise_for :users
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

  root to: redirect('/migration')

  resources :media, param: :uuid, only: :show do
    member do
      get ':size', action: :show, constraints: { size: /w[24]00/ }, as: :thumbnail
    end
  end

  resources :contributions, param: :uuid, only: %i(index show edit destroy) do
    member do
      get :delete
    end
  end

  resources :events, param: :uuid

  resources :migration, param: :uuid, only: %i(index new create edit update)

  get 'oai', to: 'oai#index'

  get 'vocabularies/europeana/places', to: 'vocabularies/europeana/places#index'
  get 'vocabularies/europeana/places/dereference', to: 'vocabularies/europeana/places#show'
  get 'vocabularies/europeana/contribute/getty_aat', to: 'vocabularies/europeana/contribute/getty_aat#index'
  get 'vocabularies/europeana/contribute/getty_aat/dereference', to: 'vocabularies/europeana/contribute/getty_aat#show'
  get 'vocabularies/geonames', to: 'vocabularies/geonames#index'
  get 'vocabularies/unesco', to: 'vocabularies/unesco#index'
  get 'vocabularies/unesco/dereference', to: 'vocabularies/unesco#show'
end
