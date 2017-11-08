Rails.application.routes.draw do
  mount ContentsCore::Engine => "/contents_core"

  resources :pages, only: [:index, :show]

  root 'pages#index'
end
