Nctuplus::Application.routes.draw do

  match 'auth/:provider/callback', to: 'sessions#create', via: [:get, :post]
  match 'auth/failure', to: redirect('/'), via: [:get, :post]
  match 'signout', to: 'sessions#destroy', as: 'signout', via: [:get, :post]
	
	root :to => "main#index"
	
#--------- for many usage --------------
  post "main/temp_student_action"
	get "main/E3Login"
	post "main/E3Login_Check"
	get "main/student_import"
	post "main/student_import"
  get "main/test"
	get "main/testttt"
	get "main/testtt11t"
	post "main/send_report"
	get "main/hidden_prepare"
  get "main/index"
#---------- for many usage end -----------
	
	get "admin/ee104"
	
#---------- user ----------------	
	get "user/add_course"
	get "user/get_courses"
	get "user/this_sem"
	post "user/import_course"
	get "user/import_course"
	get "user/import_course_2"
	get "user/select_cs_cf"
	get "user/statistics2"
	get "user/select_cm"
	post "user/select_cm"
	get "user/select_cf"
	get "user/change_role"
	get "user/statistics_table"
  get "user/manage"
	get "user/import_course"
  get "user/special_list"
	get "user/all_courses"
	get "user/statistics"
  get "user/:id/permission", to: "user#permission"
  post "user/:id/permission", to: "user#permission"
	post "user/select_dept"
  post "user/create"
	
#--------- user end -------------
	

	post "courses/comment_submit"
	post "courses/course_raider"
	post "courses/course_content_post"
	get "courses/groups"
	get "courses/get_compare"	
	get "courses/search_mini"
	get "courses/course_raider"
	get "courses/list_all_courses"
  get "courses/rate_cts"
	get "courses/simulation"
	get "courses/get_user_courses"
	get "courses/get_sem_form"
	get "courses/raider_list_like"
  get "courses/timetable"
	get "courses/add_to_cart"
	get "courses/show_cart"
	resources :courses
	

#### course map block 	
	#get "course_maps/add_usercoursemapship"		
	get "course_maps/get_course_tree"
	get "course_maps/get_group_tree"
	post "course_maps/course_action"
	post "course_maps/action_new"
	post "course_maps/action_update"
	post "course_maps/action_delete"	
	post "course_maps/action_fchange"
	get "course_maps/show_course_list" 
	get "course_maps/show_course_group_list"
	post "course_maps/course_group_action"
	get "course_maps/start2"
	resources :course_maps
####
	
	resources :departments do
    resources :courses
	end
		
	get "discusses/list_by_course"
	get "discusses/like"
	post "discusses/new_discuss"
	post "discusses/new_sub_discuss"
	post "discusses/update_discuss"
	post "discusses/delete_discuss"
 

	
	# for ems curl
	post "/main/get_specified_classroom_schedule"
	
	#----------for chrome extension---------------
	post "api/query_from_time_table"
	post "api/query_from_cos_adm"
	get "api/testttt"
  #----------for files---------------
  
	get "file_infos/list_by_ct"
	get "file_infos/add_count"
  get "file_infos/edit"
  resources :file_infos
  
  
  #----------for user---------------



  
	get "course_details/mini"
	get "course_details/course_group"
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
