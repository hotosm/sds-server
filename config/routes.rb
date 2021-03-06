HotJosm::Application.routes.draw do

   root :to => "sessions#new"

   resources :users
   match 'change_password', :to => "users#change_password", :via => :get
   match 'update_password', :to => "users#update_password", :via => :put
   
   resources :osm_shadows
   resources :sessions, :only => [:new, :create, :destroy]
   
   resources :projects do
     get :data, :on => :member
     resources :users, :only => [:index]
   end

   match '/mapsearch', :to => 'search#mapsearch'
   match '/tagsearch', :to => 'search#tagsearch'

   match '/signin',  :to => 'sessions#new'
   match '/signout', :to => 'sessions#destroy'

   match '/home',    :to => 'home#index'
   match '/status',  :to => 'home#status'

   match '/osmapi/*apirequest',  :to => 'osmapi#proxy'

   resources :tags, :only => [:show] do
     put :revert, :on => :member
   end
  
   match '/osm_shadows/show/:osm_type/:osm_id', :to =>'osm_shadows#list', :as => 'list_shadows'
   #match '/osm_shadows/edit/:osm_type/:osm_id', :to =>'osm_shadows#edit', :as => 'edit_shadow'
   #match '/osm_shadows/new/:osm_type/:osm_id',  :to =>'osm_shadows#new',  :as => 'new_shadow'

   match '/createshadows',    :to => 'josmapi#createshadows'
   match '/collectshadows',   :to => 'josmapi#collectshadows'


   # XXX 
   # resources :osm_shadows do
   #   resources :tags
   # end


  #get "home/index"

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
