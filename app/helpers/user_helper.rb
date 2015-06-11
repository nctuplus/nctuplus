module UserHelper
  #def cm_find(department_id,user_id)
  #  @usermanager=UserManager.where(:department_id=>department_id, :user_id=>user_id)
  #end
	def progress_bar(current,total)
		if total!=0
		width = current > total ? 100 : (current*100) / total
		end
		html='<div class="progress no-margin-bottom" style="//margin-top:0px;">'
		html<<"<div class='progress-bar progress-bar-success' style='width:#{width}%'>"
		html<<'<span><strong>'
		html<<"#{current}/#{total}</strong></span></div></div>"
				
			
		return html.html_safe
	end
	def green_check
		return  fa_icon("check 2x", :style=>"color:#5cb85c")
	end
	def red_x
		return  fa_icon("times 2x", :style=>"color:#E35553")
	end
	
	def grade_on_user(user, semester)
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
	def can_add_to_collection?(current_user, user, item)
		return (current_user and current_user != user and current_user.hasCollection?(item))
	end	
	
end
