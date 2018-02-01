# frozen_string_literal: true

# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
Rails.application.routes.draw do
  devise_for :users
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

  root to: redirect('/migration')

  resources :stories, only: :index

  resources :migration, only: %i(index new create)

  get 'oai', to: 'oai#index'

  get 'vocabularies/europeana/places', to: 'vocabularies/europeana/places#index'
  get 'vocabularies/geonames', to: 'vocabularies/geonames#index'
  get 'vocabularies/unesco', to: 'vocabularies/unesco#index'
end
