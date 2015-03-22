Nctuplus::Application.routes.draw do
	
	root :to => "main#welcome"
	
	
	resources :events
	
#--------- login control and session --------------
  match 'auth/:provider/callback', to: 'sessions#create', via: [:get, :post]
  match 'auth/failure', to: redirect('/'), via: [:get, :post]
  match 'signout', to: 'sessions#destroy', as: 'signout', via: [:get, :post]
	get "sessions/get_courses"
	
	

#--------- for many usage --------------
	get "main/welcome"
	get "main/index"
  post "main/temp_student_action"
	get "main/E3Login"
	post "main/E3Login_Check"
	get "main/student_import"
	post "main/student_import"
  get "main/test"
	post "main/send_report"
	get "main/policy_page"
  
#---------- admin page -----------
	
	get "admin/ee104"
	get "admin/users"
	
#---------- user ----------------
	get "user/change_role" #in admin/users
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
	
	###
	get "course_content/get_course_info"
	get "course_content/show" # testing
	post "course_content/course_action"
	
	post "courses/comment_submit"
	post "courses/course_content_post"
	get "courses/get_compare"	
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
	resources :course_maps
####
	
	resources :departments
	
	
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
  get "file_infos/edit"
  resources :file_infos
  
    

end
