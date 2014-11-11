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
	
		# cfg pass=2 => course_group
	#	course_group_cfg = CourseFieldGroup.new
	#	course_group_cfg.course_map_id, course_group_cfg.pass, course_group_cfg.user_id = @course_map.id, 2, current_user.id
	#	course_group_cfg.save!
		
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
	
	# type=0 course_field(content), type=1 course_field(header), type=2 course_field_group 
	# type=-1 new course_field_group, type=-2 new course_field (header), type=-3 new course_field (content)
	def get_course_tree
		if request.xhr? # if ajax
			list = []
			data = CourseMap.includes(:course_field_groups).find(params[:map_id])
			data.course_field_groups.where('pass != 2').includes(:course_fields).order('pass ASC').each do |cfg|
				sub = {}
				if cfg.pass == 1				
					if cfg.course_fields.empty? #刪 必,多 時，因為只傳cf id 沒法刪到cfg，在這刪掉留下的
						cfg.destroy
						next
					else
						content = cfg.course_fields.last  # .includes(:course_field_lists)
						sub = cf_parse(content, 0)	
										
					end 					
				else		
					sub = cfg_parse(cfg, 0)						
				end	
				list.push(sub)	
			end
			list.push({:text=>'新增類別', :type=>-1, :icon=>'fa fa-plus text-success', :parent_id=>params[:map_id]})
	#	Rails.logger.debug "[debug] " + list.to_s
		end# if
	
		respond_to do |format|
   	 		format.json {render :layout => false, :text=>list.to_json}
    	end
	end
	
	# type = 0 course_group list, type = -1 new course group
	# field_type=4 代表, field_type=5 抵免
	def get_group_tree
		if request.xhr? # if ajax
			list = []
			cg = CourseMap.find(params[:map_id]).course_groups
			unless cg.empty?
				cg.each do |group|
					tmp = {:text=>group.lead_course ? group.lead_course.ch_name : "未選代表課", :cg_id=>group.id, :type=>0, :gtype=>group.gtype}
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
		@target_id = nil
		
		map_id = params[:map_id]
		target_id = params[:target_id]
		name = params[:name]
		@course_map = CourseMap.find(map_id)
		case params[:action_type]		
			when 'course_field_group'			
				case params[:group_type].to_i
					when 1..2 #必, 多
						cfg = CourseFieldGroup.new
						cfg.course_map_id, cfg.user_id, cfg.pass = @course_map.id, current_user.id, 1
						cfg.save!
						cf = CourseField.new
						cf.course_field_group_id = cfg.id
						cf.name, cf.user_id, cf.field_type  = name, current_user.id, params[:group_type].to_i
						cf.save!
						@target_id = cf.id
					when 3 #領
						cfg = CourseFieldGroup.new
						cfg.name = name
						cfg.course_map_id, cfg.user_id, cfg.pass = @course_map.id, current_user.id, 0
						cfg.save!
						@target_id = cfg.id
				end
			when 'course_field_head'
				
				cfg = CourseFieldGroup.find(target_id)
				cfh = CourseField.new
				cfh.course_field_group_id, cfh.name, cfh.user_id, cfh.field_type = target_id, name, current_user.id, 0
				cfh.save!
				@target_id = cfh.id
			when 'course_field_content'
			
				cfh = CourseField.find(target_id)
				cfc = CourseField.new
				cfc.user_id, cfc.name, cfc.field_type = current_user.id, name, ((params[:group_type].to_i==3) ? 0 : params[:group_type].to_i)	
				cfc.save!
				cfs = CourseFieldSelfship.new
				cfs.parent_id, cfs.child_id = cfh.id, cfc.id
				cfs.save!
				@target_id = cfc.id
		end

		render :text=> @target_id.to_s
	end

	def action_update
		if params[:level].to_i == 1 # cfg
			cfg = CourseFieldGroup.find(params[:target_id])
			cfg.name = params[:name]
			cfg.credit_need = params[:credit_need].to_i
			cfg.field_need = params[:field_need].to_i
			cfg.save!
		else # cf
			cf = CourseField.find(params[:target_id])
			cf.name = params[:name]
			cf.credit_need = (params[:credit_need].to_i==-1) ? 0 : params[:credit_need].to_i
			cf.save!
		end	
		render :nothing => true, :status => 200, :content_type => 'text/html'
	end

	def action_delete # ajax POST
		case params[:level].to_i
			when 0 # 
				cg = CourseField.find(params[:target_id])
				cg.destroy
			when 1 # cf
				cfg = CourseFieldGroup.find(params[:target_id])
				cfg.destroy
		end
		render :nothing => true, :status => 200, :content_type => 'text/html'
	end
	
	def show_course_list	
		
		cg = CourseField.find(params[:target_id])
		data = []
		cg.course_field_lists.includes(:course).each do |list|
			course = list.course
			tmp = {:id=>list.id, :course_id=>list.course_id ,:course_name=>course.ch_name,
			:dep=>course.department.ch_name,:credit=>course.course_details.first.credit,
			:record_type=>list.record_type }
			if list.course_group_id  # it is a group header
				cg = CourseGroup.find(list.course_group_id)
				groups = []
				cg.course_group_lists.includes(:course).reject{|l| l.course==course}.each do |l|
					tmp2 = {:course_name=>l.course.ch_name, :dep=> l.course.department.ch_name, :credit=> l.course.course_details.last.credit}
					groups.push(tmp2)
				end
				tmp[:groups] = groups
			end			
			
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
				all_courses = cf.course_field_lists.map{|li| li.course_id.to_s}
				fail_cnt = 0
				success_cnt = 0
			##  check if is course group header
				course_groups = CourseMap.find(params[:map_id]).course_groups.includes(:course_group_lists)
			#	Rails.logger.debug "[debug hit] " + course_groups.map{|m| m.course_id}.to_s
				c_ids.each do |c_id|
					if all_courses.include? c_id
						fail_cnt +=1
						next
					end
				
					cfl = CourseFieldList.new
					cfl.course_field_id = cf.id
					cfl.user_id = current_user.id
					
					# check course group
					hit = course_groups.select{|g| g.lead_course.id==c_id.to_i}	
			#		Rails.logger.debug "[debug c_id] " + c_id.to_s
					unless hit.empty?
						cfl.course_group_id = hit.last.id
					end
					
					cfl.course_id = c_id
					cfl.save!
					success_cnt += 1
				end
				data[:success], data[:fail] = success_cnt, fail_cnt
			when 'add_group'
				cg = CourseGroup.find(params[:cg_id])
				c_ids = params[:c_ids]
				all_courses = cg.course_group_lists.map{|li| li.course_id.to_s}
				fail_cnt = 0
				success_cnt = 0
				c_ids.each do |c_id|
					if all_courses.include? c_id
						fail_cnt +=1
						next
					end
					cgl = CourseGroupList.new
					cgl.course_group_id, cgl.course_id = cg.id, c_id
					cgl.user_id, cgl.lead = current_user.id, 0
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
				cfl = CourseFieldList.find(params[:target_id])
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
					cg.destroy
				else #cgl
					cgl = CourseGroupList.find(params[:list_id])	
					if cgl.lead==1		
						cg = CourseField.find(params[:cg_id])
						#cg.name = '未選代表課'
						#cg.course_id = nil
						cg.save!
					end
					cgl.destroy
				end
				data = {:success=>1}.to_json
		end
		render :text=> data
	end
	
	

private
  
  def cf_parse(cf, level)
  	if cf.field_type != 0
  		chead = (cf.field_type==1) ? "[必修] " : "[X選Y] "
  		data = {:text=>(chead+cf.name), :type=>0, :cf_id=>cf.id}  
  		data[:label], data[:name] = chead, cf.name
			data[:icon] = (cf.field_type==1) ? "fa fa-star" : "fa fa-check-square-o"
  		data[:credit_need] = (cf.field_type==1) ? "N/A" : cf.credit_need.to_s
  		#data[:backColor] = color_level(level)		
		#data[:color] = (level==0) ? '#FFFFFF' : '#000000'
		if cf.field_type==2
			data[:tag] = [ cf.credit_need.to_s ]
		end
	else	
		chead = (level==1) ? "[領域] " : "[群組] "
		data = {:text=>(chead + cf.name), :type=>1, :cf_id=>cf.id}
		data[:label], data[:name], data[:icon] = chead, cf.name, 'fa fa-share-alt-square'
		data[:credit_need] = cf.credit_need
		#data[:tags] = [ "C(#{cf.credit_need})" ]

		#data[:backColor] = color_level(level)
		#data[:color] = (level==0) ? '#FFFFFF' : '#000000'
		nodes = []
		cf.course_fields.order('field_type ASC').each do |sub|
			nodes.push(cf_parse(sub, level+1))
		end
		nodes.push({:text=>'新增群組', :type=>-3, :parent_id=>cf.id, :icon=>'fa fa-plus text-success'})	
		data[:nodes] = nodes
	end
	return data
  end
  
  def cfg_parse(cfg, level) # for each cfg
  	data = {}
  	data[:text] = "[領域群組] " + cfg.name
  	data[:label], data[:name] = "[領域群組]", cfg.name
	data[:type], data[:icon], data[:tags] = 2, 'fa fa-share-alt-square', [ "F(#{cfg.field_need})","C(#{cfg.credit_need})"]
	data[:cfg_id], data[:credit_need], data[:field_need] = cfg.id, cfg.credit_need, cfg.field_need
	#data[:backColor] = color_level(level)
	#data[:color] = (level==0) ? '#FFFFFF' : '#000000'
	nodes = []
	cfg.course_fields.order('field_type ASC').each do |cf|
		nodes.push(cf_parse(cf, level+1))
	end
	nodes.push({:text=>'新增領域', :type=>-2, :parent_id=>cfg.id, :icon=>'fa fa-plus text-success'})	
	data[:nodes] = nodes
	
	return data
  end

  def color_level(l)
  	case l
  		when 0 
  			return '#088A08'
  		when 1 
  			return '#58FA58'
  		when 2 
  			return '#A9F5A9'
  		else
  			return '#E0F8E0'
	
  	end
  end
	
end
