Rails.application.routes.draw do
  resources :guests do
    collection do
      get 'import'
      post 'import', to: 'guests#process_import'
      get 'new_guest', to: 'guests#new_guest'
    end
  end

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
  post 'email/bulkReferral'

  namespace :api, except: [:new, :edit] do
    namespace :v1 do
      resources :users, except: [:create]
      post '/email/bulk' => 'email#bulk'
      post '/email/bulkReferral' => 'email#bulkReferral'
      post '/email' => 'email#create'
      post '/guest/set_expiry' => 'guests#set_expiry'
      post '/guest/get_expired' => 'guests#get_expired'
      
      post '/events/:event_id/guests/:id/:sumofall/updateguestcommitted' => 'guests#updateguestcommitted'
      get '/events/:event_id/guests/:id/sum_all' => 'guests#sum_all'
      
      
      
      get '/events/:event_id/guests/mail' => 'guests#mail'
      get '/events/:event_id/guests/:id/countmail' => 'guests#countmail'


      get '/guest/count_all' => 'guests#count_all'
      get '/sale_tickets/count_all' => 'sale_tickets#count_all'
      get '/events/:event_id/guests/count_all' => 'guests#count_all'
      get '/events/:event_id/sale_tickets/count_all' => 'sale_tickets#count_all'
      resources :events do
        get '/summary' => 'events#summary'
        get '/headers/:id' => 'events#headers'
        get '/dataload/:header/:firstName/:lastName/:email/:seatLevel/:seats' => 'events#dataload'
        resource :guest_referrals, path: :refer, only: [:show, :create]
        resource :guest_referees, path: :purchase, only: [:show, :create]
        resources :guests do
          member do
            get :invite
            get :checkin
            patch :book
            resource :tickets
          end
        end
        resources :sale_tickets
        resources :boxoffice_headers, only: [:index] do
      get :header_names, on: :collection
    end
        resources :email_templates, path: :templates
        resources :referral_rewards, path: :rewards
        resources :referral_summary, only: [:index]
        resources :seats
      end
    end
        # to access api/v2/users
    namespace :v2 do 
      resources :users, only: [:index, :show, :update, :destroy]
    end
    #if your application is hosted at http://example.com 
    #and endpoint is at api/v2/users, 
    #you can make a request to http://example.com/api/v2/users to get a list of users.
  end
  
  resources :events do
    resource :refer
    resource :purchase
    resource :book
    resources :guests
    resources :seating_types
    resources :sale_tickets
    resources :boxoffice_headers
  end

  

  post '/import_new_spreadsheet' => 'events#import_new_spreadsheet'
  post '/open_existed_spreadsheet'  => 'events#open_existed_spreadsheet', as: :open_existed_spreadsheet
  post '/seat_categories'  => 'events#seat_categories'
  post '/reconcile'  => 'events#reconcile'
  post '/create_referral' => 'events#create_referral', as: :create_referral
  
  get '/events/:event_id/guests/:id/send' => 'guests#send_email_invitation', as: :send_event_guest
  get '/events/:event_id/guests/:id/ref_count' => 'guests#update_ref_count', as: :guest_ref_count
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
