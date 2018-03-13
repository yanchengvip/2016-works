Rails.application.routes.draw do

  mount WeixinRailsMiddleware::Engine, at: "/"
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'homes#home'
  scope '/jht2' do

    get '/' => 'homes#home'

    # Example of regular route:
    #   get 'products/:id' => 'catalog#view'

    # Example of named route that can be invoked with purchase_url(id: product.id)
    #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

    # Example resource route (maps HTTP verbs to controller actions automatically):
    #   resources :products

    post '/send_check_code' => 'register#send_check_code'
    post '/valid_check_code' => 'register#valid_check_code'
    post '/signup' => 'register#create' #用户注册
    post '/user_verify' => 'register#user_verify' #用户认证
    post '/valid_mobile' => 'register#valid_mobile' #验证手机
    get '/signup' => 'register#new'

    resource :users do
      collection do
        post 'bind_order'
        get 'user_incoming'
        get 'user_info'
        get 'user_address'
        get 'user_balanced'
        get 'user_not_balanced'
        post 'update_address'
        post 'bind_order_by_admin'
      end
    end
    resource :tasks do
      collection do
        get 'list'
        get 'task_details'
        get 'user_tasks'
        post 'get_task'
        get 'user_task_details'
        post 'assign_new_tasks'
      end
    end

    resource :weixins do
      collection do
        post 'create_menus'
        post 'send_weixin_message'
        post 'send_weixin_message_by_order'
        post 'get_qrcode'
        get 'material_list'
        get 'weixin_jssign_package'
        get 'get_weixin_code'
        get 'get_weixin_code_by_url'
      end
    end
    resource :user_orders do
      get 'user_order_list'
      get 'order_details'
      post 'order_handling'
      get 'scan_qrcode_order'
      get 'qrcode_bind_order'
      post 'split_order'
    end
    resource :bank_infoes do
      collection do
        get 'bank_query'
        get 'bank_branch'
      end

    end

    resource :homes do
      collection do
        get 'home'
        get 'task'
        get 'login_again'
        get 'help'
        get 'tips'
        get 'tuiguang'
      end
    end

    resource :cities do
      collection do
        get 'show_city'
      end
    end
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

end