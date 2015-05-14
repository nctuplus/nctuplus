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
end
