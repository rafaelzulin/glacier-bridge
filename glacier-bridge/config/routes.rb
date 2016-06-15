Rails.application.routes.draw do
  get 'welcome/index'
  post 'glacier/start'
  post 'glacier/list_vaults'
  get 'glacier/list_vaults'
  get 'glacier/new_vault'
  post 'glacier/create_vault'
  delete 'glacier/destroy_vault/:id' => 'glacier#destroy_vault', as: :glacier_destroy_vault
  get 'glacier/inventory_retrieval/:id' => 'glacier#inventory_retrieval', as: :glacier_inventory_retrieval
  get 'glacier/inventory_download/:id' => 'glacier#inventory_download', as: :glacier_inventory_download
  get 'glacier/new_archive'
  post 'glacier/upload_archive'
  post 'glacier/access_register'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'welcome#index'

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
