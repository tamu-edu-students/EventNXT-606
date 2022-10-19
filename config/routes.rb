Rails.application.routes.draw do

  resources :seats
  use_doorkeeper do
    skip_controllers :applications, :authorized_applications
  end

  devise_for :users, path: '',
    path_names: {
      registration: 'register'
    },
    controllers: {
      registrations: 'registrations'
    },
    defaults: {format: :json}

  root 'welcome#index'
  post '/login' => 'login#create'
  get '/admin' => 'admin#index'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".
  # You can have the root of your site routed with "root"
  get 'events/index'
  post 'events/index'
  get 'events/create_event'
  post 'events/create_event'
  get 'events/show'
  post 'events/show'
  post 'email/bulk'

  namespace :api, except: [:new, :edit] do
    namespace :v1 do
      resources :users, except: [:create]
      post '/email/bulk' => 'email#bulk'
      post '/email' => 'email#create'
      resources :events do
        get '/summary' => 'events#summary'
        resource :guest_referrals, path: :refer, only: [:show, :create]
        resources :guests do
          member do
            get :invite
            get :checkin
            patch :book
            resource :tickets
          end
        end
        resources :email_templates, path: :templates
        resources :referral_rewards, path: :rewards
        resources :referral_summary, only: [:index]
        resources :seats
      end
    end
  end
  
  resources :events do
    resource :refer
    resource :book
    resources :guests
    resources :seating_types
  end

  

  post '/import_new_spreadsheet' => 'events#import_new_spreadsheet'
  post '/open_existed_spreadsheet'  => 'events#open_existed_spreadsheet', as: :open_existed_spreadsheet
  post '/seat_categories'  => 'events#seat_categories'
  post '/reconcile'  => 'events#reconcile'
  post '/create_referral' => 'events#create_referral', as: :create_referral
  
  get '/events/:event_id/guests/:id/send' => 'guests#send_email_invitation', as: :send_event_guest
  put '/events/:event_id/guests/:id/update_in_place' => 'guests#update_in_place', as: :update_event_guest
  
  
  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
