Rails.application.routes.draw do
  resources :pages
  root 'pages#index'
end
