Nctuplus::Application.routes.draw do

#  mount Ckeditor::Engine => '/ckeditor'
  match 'auth/:provider/callback', to: 'sessions#create', via: [:get, :post]
  match 'auth/failure', to: redirect('/'), via: [:get, :post]
  match 'signout', to: 'sessions#destroy', as: 'signout', via: [:get, :post]
  
	
	post "courses/search_by_dept"
	post "courses/search_by_keyword"
	post "courses/comment_submit"
	#post "courses/raider_submit"
	post "courses/course_raider"
	
	get "courses/course_raider"
	get "courses/list_all_courses"
  get "courses/rate_cts"
	get "courses/simulation"
	get "courses/add_simulated_course"
	get "courses/get_user_simulated"
	get "courses/get_user_courses"
	get "courses/get_sem_form"

  get "courses/special_list"

	get "courses/get_user_statics"
	
	get "courses/add_to_cart"
	get "courses/show_cart"

	resources :courses

		resources :departments do
       #resources :comments, :sales
       resources :courses #, :controller => 'department_courses'
	  #resources :course
	   
		end
  #resources
	
  resources :teachers
  
	
	post "reviews/search_by_keyword"
	get "reviews/list_all_reviews"
	
  resources :reviews
  
  #get "post/getcode"
  #resources :post
	
	post "main/send_report"
	get "main/hidden_prepare"
  get "main/index"
	
	
  #----------for files---------------
  #get "file_info/all_users"
	#get "file_infos/list_by_course"
  get "file_infos/one_user"
  #get "file_info/upload"
  #get "file_info/download"
  #get "file_info/delete_file"
  get "file_infos/edit"
  get "file_infos/pictures_show"
  resources :file_infos
  
 
  #post "files/create"
  #get "files/show"  
  #----------for user---------------
  #get "user/mail_confirm"
  get "user/activate"
  get "user/manage"
  get "user/registry"
  
  get "user/:id/permission", to: "user#permission"
  
  post "user/:id/permission", to: "user#permission"
  
	post "user/select_dept"
  post "user/create"
  #get "user/create"
  
 # resources :upload
  #root :to => "courses#show", :id=>5
  root :to => "main#index"
  
  
  
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
