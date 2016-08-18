module UserHelper
	
	def grade_on_user(user, semester)	#for user/share & user/collections
	  dy = semester.year - user.year
	  dhalf = semester.half 
	  half_name = (dhalf==1) ? "上" : "下"
	  case dy
	    when 0
	      year_name = "一"
	    when 1
	      year_name = "二"
	    when 2
	      year_name = "三"
	    else
	      year_name = "四"    
	  end
	  grade_name = user.department.degree==3 ? "大" : "研"
	  return grade_name+year_name+half_name
	end
	
# user share	
	def can_add_to_collection?(current_user, user, semester)
		return (current_user.present? and current_user != user and !current_user.hasCollection?(user.id, semester.id))
	end	
	
	def generate_share_hashid(user_id, sem_id)
	  return Hashid.user_share_encode [user_id, sem_id]
	end

# user/show
  def import_course_link
    btn_text = fa_icon("refresh")+"  匯入成績"
    url = (current_user.hasE3?) ? "/scores/import" : "javascript:void(0);"
    options = {:class=>"btn btn-warning btn-xs"}
    if !current_user.hasE3?
      options[:onclick] = 'toastr["warning"]("綁定E3以開啟此功能!");'
    end
    return link_to(btn_text, url, options)
  end
  
  def gpa_link
    btn_text = fa_icon("check")+"  GPA 計算機"
    url = (current_user.hasE3?) ? "/scores/gpa" : "javascript:void(0);"
    options = {:class=>"btn btn-warning btn-xs"}
    if !current_user.hasE3?
      options[:onclick] = 'toastr["warning"]("綁定E3以開啟此功能!");'
    end
    return link_to(btn_text, url, options)
  end
end
