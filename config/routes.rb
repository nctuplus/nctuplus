Nctuplus::Application.routes.draw do

	root :to => "main#index"
	
#----------- [devise] user account concerned -----------	
	devise_for :users, #:skip=>[:registrations, :confirmations, :passwords],
             :controllers => { :omniauth_callbacks => "callbacks"},
             :path=>"/",
             :path_names => {
              :sign_in  => 'login',
              :sign_out => 'logout' }

#--------- bulletin -----------
	resources :bulletin

#--------- slogan -----------
	resources :slogan

#--------- backgrounds -----------
	resources :backgrounds

#--------- lab -----------
	resources :lab

#--------- events -----------
	resources :events do
		collection do
			post "attend"
		end
	end
	
#--------- for share course table page -----------
	get "shares/:id" , to: "user#share", :constraints => {:id => /.{#{Hashid.user_sharecode_length}}/}
	# update user share and return json hash id 
	post "user/update", to: "user#update_user_share", :constraints => lambda{ |req| req.params[:type]=="share"}
	# update share course table image
	post "user/update", to: "user#upload_share_image", :constraints => lambda{ |req| req.params[:type]=="upload_share_image" and req.params[:semester_id] =~ /\d/ } 
	# add to user collection
	post "user/update", to: "user#user_collection_action", :constraints => lambda{ |req| req.params[:type].include? "collection"}
	# show user collections lists
	get "user/collections"
	get "user/courses"
#----------- for other usage -----------

	get "main/index"
	get "main/policy_page"
	get "main/member_intro"	
	post "/main/get_specified_classroom_schedule" # for ems curl
	get "main/fb"
	post "main/fb"

#----------- for search -----------	
	get "search/cts"
	
#----------- for development test -----------
if Rails.env.development?	
	get "main/test"
end

#---------- admin page -----------
	
 	get 	"admin/statistics"
	get 	"admin/ee105"
	get 	"admin/users"
	post 	"admin/change_role"
	post 	"admin/change_dept"
	get 	"admin/course_maps" #, to: "course_maps#admin_index"
	
#---------- user -----------
	get "user", to: "user#show"	#user personal page
	get "user/this_sem"
	get "user/statistics"
	get "user/statistics_table"
	
	get "user/add_course"
	get "user/delete_course"
	get "user/get_courses"
	get "user/all_courses"
	
	get "user/edit"
	patch "user/update"	
	get "user/select_cs_cf"
	get "user/select_cm"
	post "user/select_cm"
	
#---------- scores -----------
	post "scores/import"
	get "scores/import"
	get "scores/select_cf"
	get "scores/gpa"
	
#----------- course_content -----------
	post "course_content/raider"
	get "course_content/raider"	
	get "course_content/raider_list_like"
	get "course_content/rate_cts"
	get "course_content/get_compare"	
	get "course_content/single_compare"	
	get "course_content/get_course_info"
	post "course_content/course_action"
	
#----------- for discusses -----------
	resources :discusses do
		collection do
			get "list_by_ct"
			get "like"
		end
	end

#---------- for past_exams -----------
  resources :past_exams, :except=>[:edit] do
		collection do
			get "course_page"
			get "list_by_ct"
			get "upload"
		end
	end

	
	resources :courses, :only => [:index, :show] do
		collection do
			get "index_new"
			get "search_mini"
			get "search_mini_cm"
			get "simulation"
			get "export_timetable"
			get "add_to_cart"
			get "show_cart"
			get "tutorial"
		end
	end
	
	resources :course_maps do
	  collection do
			get "public"
			get "content"	
			get "get_course_tree"
			get "get_course_group"
			get "get_course_list"
			get "get_credit_list"
			get "search_course"
			post "credit_action"
			post "course_action"
			post "action_new"
			post "action_update"
			post "action_delete"	
			post "action_fchange"
			post "course_group_action"
			post "update_cm_head"
			post "cm_public_comment_action"
			post "notify_user"
			post "change_owner"
	  end
	end


	resources :departments, :except=>[:show, :destroy]

 

	
#---------- book page ----------- 
	post "books/google_book"
  	resources :books
	
	resources :departments, :except=>[:show, :destroy]


#---------- for chrome extension -----------
	post "api/query_from_time_table"
	post "api/query_from_cos_adm"
	post "api/import_course"
	post "api/login"

#---------- for files -----------
	resources :past_exams, :except=>[:update] do
		collection do
			get "list_by_ct"
			get "edit"
		end
	end

	post "sessions/save_lack_course"

end
