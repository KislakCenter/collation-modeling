Rails.application.routes.draw do
  resources :manuscripts do
    resources :quires, only: [ :create, :new, :destroy ]
  end

  post 'manuscripts/:manuscript_id/create_quires' => 'bulk_quires#create', as: 'create_quires'

  get 'manuscripts/xml/:id', to: 'manuscripts#export_xml', as: 'manuscript_xml'

  put 'manuscripts/:manuscript_id/leaves/:id/renumber' => 'numberings#update', as: 'update_numbering'

  devise_for :users
  root to: 'manuscripts#index'

  resources :quires, only: [ :edit, :show, :update ]

  # get ':controller/:action/:id/with_user/:user_id'



  resources :leaves, only: [ :destroy ]


  get 'welcome/index'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

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
