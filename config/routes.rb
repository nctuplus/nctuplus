Nctuplus::Application.routes.draw do

#  mount Ckeditor::Engine => '/ckeditor'
  match 'auth/:provider/callback', to: 'sessions#create', via: [:get, :post]
  match 'auth/failure', to: redirect('/'), via: [:get, :post]
  match 'signout', to: 'sessions#destroy', as: 'signout', via: [:get, :post]
	
  #post "courses/update_discuss"
	#post "courses/new_discuss"
	#post "courses/new_sub_discuss"
	post "courses/search_by_dept"

	post "courses/search_by_keyword"
	post "courses/comment_submit"
	#post "courses/raider_submit"
	post "courses/course_raider"
	post "courses/course_content_post"
	
	get "courses/search"
	get "courses/get_compare"
	#get "courses/get_discuss"
	
	get "courses/course_raider"
	get "courses/list_all_courses"
  get "courses/rate_cts"
	get "courses/simulation"
	get "courses/add_simulated_course"
	get "courses/get_user_simulated"
	get "courses/get_user_courses"
	get "courses/get_sem_form"
	get "courses/raider_list_like"
	get "courses/del_simu_course"
  	get "courses/get_user_xls"

	get "courses/get_user_statics"
	
	get "courses/add_to_cart"
	get "courses/show_cart"

	resources :courses

	resources :departments do
    resources :courses
	end
		
	get "discusses/list_by_course"
	get "discusses/like"
	post "discusses/new_discuss"
	post "discusses/new_sub_discuss"
	post "discusses/update_discuss"
	post "discusses/delete_discuss"
 

	post "reviews/search_by_keyword"
	get "reviews/list_all_reviews"
	
  resources :reviews
  
  #get "post/getcode"
  #resources :post
	
	post "main/send_report"
	get "main/hidden_prepare"
  get "main/index"
	
	
  #----------for files---------------
  
	get "file_infos/list_by_ct"
	get "file_infos/add_count"
  get "file_infos/edit"
  resources :file_infos
  
  
  #----------for user---------------
  #get "user/mail_confirm"
  #get "user/activate"
	get "user/add_top_manager"
	post "user/add_course"
  get "user/manage"
	get "user/import_course"
  get "user/special_list"
  get "user/:id/permission", to: "user#permission"
  
  post "user/:id/permission", to: "user#permission"
  
	post "user/select_dept"
  post "user/create"
  #get "user/create"
  
 # resources :upload
  #root :to => "courses#show", :id=>5
  root :to => "main#index"
	
	get "course_details/mini"
  resources :course_details
  
  
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
