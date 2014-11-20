class CourseMapsController < ApplicationController
	include CourseMapsHelper

	before_filter :checkLogin

##### resource controller
	def index
		@course_maps=CourseMap.all
	end

	def show
		@course_map=CourseMap.find(params[:id])
	end

	def new
		@course_map=CourseMap.new
		render "_form"
	end

	def create
		@course_map = CourseMap.new
		@course_map.semester_id = (params[:semester_id].presence) ? params[:semester_id] : 0	
		@course_map.name, @course_map.department_id = params[:name], params[:course_map][:department_id]
		@course_map.desc = params[:course_map][:desc]
		@course_map.user_id, @course_map.like = current_user.id, 0
		@course_map.save!
	
		redirect_to @course_map
	end
	
	def destroy
		@map = CourseMap.find(params[:id])
		@map.destroy
		redirect_to :action => :index
	end
	
	def edit
	end

	def update
		@course_group=CourseGroup.find(params[:id])
		@course_group.update_attributes(course_group_param)

    redirect_to :action => :index
	end
########## 11/08 new
	
	def start2
		@course_map = CourseMap.find(params[:map_id])
		render "start2", :layout=>false		
	end
	
	def get_course_tree
		if request.xhr? # if ajax
			list = []
			data = CourseMap.find(params[:map_id])
			data.course_fields.order('field_type ASC').each do |cf|	
				sub = cf_trace(cf, :_get_field_content_data, :_get_add_field_node)											
				list.push(sub)	
			end		
			list.push({:text=>'新增類別', :type=>-1, :icon=>'fa fa-plus text-success', :parent_id=>params[:map_id]})
		end# if
	
		respond_to do |format|
   	 		format.json {render :layout => false, :text=>list.to_json}
    	end
	end
	
	def get_group_tree
		if request.xhr? # if ajax
			list = []
			cg = CourseMap.find(params[:map_id]).course_groups.order('gtype ASC')
			unless cg.empty?
				cg.each do |group|
					tmp = {:text=>group.lead_course ? group.lead_course.ch_name : "未選代表課", 
							:cg_id=>group.id, 
							:type=>0, 
							:gtype=>group.gtype,
							:icon=>(group.gtype==1) ? 'fa fa-bookmark-o' : 'fa fa-sitemap'}
					list.push(tmp)
				end
			end
			list.push({:text=>'新增群組', :type=>-1, :icon=>'fa fa-plus text-success', :parent_id=>params[:map_id]})
		end
		#Rails.logger.debug "[debug] " + list.to_s
		respond_to do |format|
   	 		format.json {render :layout => false, :text=>list.to_json}
    	end
	end
	
	def action_new
		level = params[:level].to_i
		parent_id = params[:parent_id]
		name = params[:name]
		field_type = params[:field_type].to_i
	# new cf
		cf = CourseField.new
		cf.name, cf.field_type, cf.user_id = name, field_type, current_user.id
		cf.save!
	# if 領域, add field_need table row
		if field_type==3
			fd = CfFieldNeed.new
			fd.course_field_id, fd.field_need = cf.id, 0
			fd.save!
		end 
	# create relation to it's parent
		if level==-1
			cmcf = CmCfship.new
			cmcf.course_map_id, cmcf.course_field_id = parent_id, cf.id
			cmcf.save!
		else
			cfship = CourseFieldSelfship.new
			cfship.parent_id, cfship.child_id = parent_id, cf.id
			cfship.save!
		end
		
		render :text=> cf.id.to_s
	end

	def action_update
		cf = CourseField.find(params[:target_id])
		cf.name = params[:name]
		cf.credit_need = (params[:credit_need].to_i==-1) ? 0 : params[:credit_need].to_i
		if cf.field_need
			cf_fd = cf.cf_field_need
			cf_fd.field_need = params[:field_need].to_i
			cf_fd.save!
		end
		cf.save!
	
		render :nothing => true, :status => 200, :content_type => 'text/html'
	end

	def action_delete # ajax POST 
		cf = CourseField.find(params[:target_id])
		cmcf = CmCfship.where(:course_field_id=>cf.id)
		cmcf.last.destroy unless cmcf.empty?
		cfship = CourseFieldSelfship.where(:child_id=>cf.id)
		cfship.last.destroy unless cfship.empty?
		cf.destroy
		render :nothing => true, :status => 200, :content_type => 'text/html'
	end
	
	def show_course_list	
		
		cf = CourseField.find(params[:target_id])
		data = []
		cf.course_field_lists.includes(:course).each do |list|
			course = nil
			if list.course_group_id  # it is a group header
				cg = list.course_group
			#	leader = cg.lead_group_list
				groups = []
				cg.course_group_lists.includes(:course).each do |cgl|				
					if cgl.lead == 1
						course = cgl.course
					else
						c = cgl.course
						tmp2 = {:course_name=>c.ch_name, :dep=> c.department.ch_name, :credit=> c.course_details.last.credit}
						groups.push(tmp2)
					end
				end
				
			else
				groups = nil
				course = list.course	
			end		
			
			tmp = {
			:id=>list.id, 
			:course_id=>course.id ,
			:course_name=>course.ch_name,
			:dep=>course.department.ch_name,
			:credit=>course.course_details.first.credit,
			:record_type=>list.record_type,
			:groups=> groups
			 }
			
			data.push(tmp)	
		end
	#	Rails.logger.debug "[debug] " + data.to_s
		respond_to do |format|
   	 		format.json {render :layout => false, :text=>data.to_json}
    	end
	end
	
	def show_course_group_list
		cg = CourseGroup.find(params[:target_id])
		data = []
		cg.course_group_lists.each do |l|
			course = l.course
			tmp = {:id=>l.id, :course_id=>l.course_id ,:course_name=>course.ch_name,
				   :dep=>course.department.ch_name,:credit=>course.course_details.first.credit,
				   :leader=>(l.lead==0) ? false : true }
			
			data.push(tmp)
		end
		
		respond_to do |format|
   	 		format.json {render :layout => false, :text=>data.to_json}
    	end
	end
	
	def course_action # ajax 
		data = {}
		case params[:type]
			when 'add_course'
				cf = CourseField.find(params[:cf_id])
				c_ids = params[:c_ids]
				all_courses = cf.course_field_lists.map{|li| li.course_id}
				fail_cnt = 0
				success_cnt = 0
			##  check if is course group header
				course_group_leads = CourseMap.find(params[:map_id]).course_groups.includes(:course_group_lists)
									 .reject{|cg| cg.course_group_lists.count==0 or cg.gtype==1}
									 .map{|cg| [cg.id, cg.lead_group_list.course_id]}
				#Rails.logger.debug "[debug hit] " + course_group_leads.to_s	
				c_ids.each do |c_id|
					if all_courses.include? c_id.to_i
						fail_cnt +=1
						next
					end
				
					cfl = CourseFieldList.new
					cfl.course_field_id = cf.id
					cfl.user_id = current_user.id
					
					# check course group
					hit = course_group_leads.select{|d1, d2| d2==c_id.to_i}
					if not hit.empty?					
						cfl.course_group_id = hit.last[0]
					else	
						cfl.course_id = c_id
					end
					cf.credit_need += Course.find(c_id).credit
					cfl.save!
					success_cnt += 1
				end
				cf.save!
=begin				
				cf = CourseField.find(params[:cf_id]) # reload
				if cf.field_type.to_i==1
					all_credit = 0
					cf.course_field_lists.each do |d|
						if d.course_group_id.presence
							lead = d.course_group.lead_group_list.course
							Rails.logger.debug "[debug] lead_course "+lead.ch_name+" "+lead.credit.to_s
							all_credit += lead.credit
						else
							Rails.logger.debug "[debug] course"+d.course.ch_name+" "+d.course.credit.to_s
							all_credit += d.course.credit
						end
					end	
					cf.credit_need = all_credit
					cf.save!
				end		
=end					
				data[:success], data[:fail] = success_cnt, fail_cnt
			when 'add_group'
				cg = CourseGroup.find(params[:cg_id])
				c_ids = params[:c_ids]
				all_courses = cg.course_group_lists.map{|li| li.course_id}
				fail_cnt = 0
				success_cnt = 0
				has_lead = (cg.lead_group_list.presence) ? true : false
				c_ids.each do |c_id|
					if all_courses.include? c_id.to_i
						fail_cnt +=1
						next
					end
					cgl = CourseGroupList.new
					cgl.course_group_id, cgl.course_id = cg.id, c_id
					cgl.user_id= current_user.id
					cgl.lead = (has_lead) ? 0 : 1
					cgl.save!
					success_cnt += 1
				end
				
				data[:success], data[:fail] = success_cnt, fail_cnt	
			when 'update'
				cfl = CourseFieldList.find(params[:target_id])
				cfl.record_type = params[:rtype].to_i
				cfl.save!
				data[:success] = 1	
			when 'delete'
				cf = CourseField.find(params[:cf_id])
				cfl = CourseFieldList.find(params[:target_id])
				if cf.field_type.to_i==1
					credit = 0
					if cfl.course_group_id
						credit = cfl.course_group.lead_group_list.course.credit
					else
						credit = cfl.course.credit
					end
					cf.credit_need -= credit
					cf.save!
				end
				cfl.destroy
				
				
				data[:success] = 1	
			else
				data[:fail] = 1	
		end
		render :text=>data.to_json#, :layout=> false
	end
	
	def course_group_action #ajax POST	
		data = nil
		case params[:type]
			when 'new' # new course group
				cg = CourseGroup.new
				cg.course_map_id, cg.user_id = params[:map_id], current_user.id
				cg.gtype = 0 ;
				cg.save!
				data = cg.id
			when 'update' # update course list type or set leader
				if params[:target]=='gtype'
					cg = CourseGroup.find(params[:cg_id])
					cg.gtype = params[:gtype]				
				else # leader
					cgl = CourseGroupList.find(params[:list_id])
					cgl.lead = 1
					cgl.save!
					
					cg = CourseGroup.find(params[:cg_id])
					cg.course_group_lists.reject{|l| l==cgl}.each do |c|
						c.lead = 0
						c.save!
					end			
					#cg.course_id = cgl.course_id		
					#cg.name = cgl.course.ch_name
				end
				cg.save!
				data = {:success=>1}.to_json
			when 'delete' # delete course
				if params[:target] == 'cg'		
					cg = CourseGroup.find(params[:cg_id])
					CourseFieldList.where(:course_group_id=>cg.id).destroy_all
					cg.destroy
				else #cgl
					cgl = CourseGroupList.find(params[:list_id])	
					if cgl.lead==1		
						cg = CourseField.find(params[:cg_id])
						cg.save!
					end
					cgl.destroy
				end
				data = {:success=>1}.to_json
		end
		render :text=> data
	end
	
	def statistics_table
		
		render :layout=> false
	end

private
  
  def _get_field_content_data(cf)		
		chead = (cf.field_type==1) ? "[必修] " : "[X選Y] "
		data = {
			:text=>(chead+cf.name),
			:type=>cf.field_type,
			:cf_id=>cf.id,
			:label=>chead, 
			:name=>cf.name,
			:icon => (cf.field_type==3) ? "fa fa-star" : "fa fa-check-square-o",
			:credit_need => (cf.field_type==3) ? "N/A" : cf.credit_need.to_s,
			:tag=>cf.field_type==2 ? [cf.credit_need.to_s] : ""
		}  

		return data
  end
  
  
  def _get_add_field_node(cf,nodes)
		chead = (cf.field_type==3) ? "[領域群組] " : "[領域] "
		nodes.push({:text=>'新增類別', :type=>(cf.field_type==3) ? -2 : -3, :parent_id=>cf.id, :icon=>'fa fa-plus text-success'})	
		data = {
			:text=>(chead + cf.name),
			:type=>cf.field_type,
			:cf_id=>cf.id,
			:label=>chead,
			:name=>cf.name,
			:icon=>'fa fa-share-alt-square',
			:credit_need=>cf.credit_need,
			:field_need=>cf.field_type==3 ? cf.field_need : nil,
			:nodes=>nodes
		}
		return data
  end

  
	
end
