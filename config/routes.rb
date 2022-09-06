Rails.application.routes.draw do
  get 'business/index'
  get 'business/show'
  devise_for :admins
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html


  namespace :admin do
    resources :dashboard, only: [:index]
  end

  namespace :api, defaults: {format: 'json'} do
    post   'users/sign_up'  => '/api/users#sign_up'
    post   'users/sign_in'  => '/api/users#sign_in'
    delete 'users/sign_out' => '/api/users#sign_out'
    
    post 'users/forgot' => '/api/users#forgot'
    post 'users/reset' => '/api/users#reset'
    resources :business
  end

  root 'admin/dashboard#index'
end
