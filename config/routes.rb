Nctuplus::Application.routes.draw do
	
	root :to => "main#index"
	
	
	resources :events
	
#--------- login control and session --------------
  match 'auth/:provider/callback', to: 'sessions#create', via: [:get, :post]
  match 'auth/failure', to: redirect('/'), via: [:get, :post]
  match 'signout', to: 'sessions#destroy', via: [:get, :post]
  match 'signin', to: 'sessions#sign_in', via: [:get, :post]	
	get "sessions/get_courses"
	
	

#--------- for many usage --------------

	
	get "main/index"
 	post "main/temp_student_action"
	#get "main/E3Login"
	#post "main/E3Login_Check"
	get "main/student_import"
	post "main/student_import"
  get "main/test"
	post "main/send_report"
	get "main/policy_page"
  
#---------- admin page -----------
	
	get "admin/ee104"
	get "admin/users"
	post "admin/change_role"
	get "admin/course_maps" #, to: "course_maps#admin_index"
#---------- user ----------------
	
	get "user/add_course"
	get "user/get_courses"
	get "user/this_sem"
	post "user/import_course"
	get "user/import_course"
	get "user/import_course_2"
	get "user/select_cs_cf"
	get "user/select_cm"
	post "user/select_cm"
	get "user/select_cf"
	
	get "user/statistics_table"

  get "user/special_list"
	get "user/all_courses"
	get "user/statistics"
	post "user/select_dept"

	
#--------- user end -------------
	post "course_content/raider"
	get "course_content/raider"	
	get "course_content/raider_list_like"
	get "course_content/rate_cts"
	get "course_content/get_compare"	
	###
	get "course_content/get_course_info"
	#get "course_content/show" # testing
	post "course_content/course_action"
	
#	post "courses/comment_submit"
#	post "courses/course_content_post"

	get "courses/search_mini"
	get "courses/search_mini_cm"
  
	get "courses/simulation"
	
  get "courses/timetable"
	get "courses/add_to_cart"
	get "courses/show_cart"
	resources :courses
	

#### course map block 	
	#get "course_maps/add_usercoursemapship"
	get "course_maps/xyz"
	#post "course_maps/xyz"
	get "course_maps/get_credit_list"
	post "course_maps/credit_action"
	
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
	post "course_maps/update_cm_head"
	get "course_maps/public"
	get "course_maps/public2"
	post "course_maps/cm_public_comment_action"
	
	resources :course_maps
####
	
	resources :departments
	
	
	get "discusses/show"
	get "discusses/like"
	post "discusses/new"
	post "discusses/update"
	post "discusses/delete"
 

	
	# for ems curl
	post "/main/get_specified_classroom_schedule"
	
	#----------for chrome extension---------------
	post "api/query_from_time_table"
	post "api/query_from_cos_adm"
	get "api/testttt"
  #----------for files---------------
  
	get "past_exams/list_by_ct"
  get "past_exams/edit"
  resources :past_exams
  
    

end
