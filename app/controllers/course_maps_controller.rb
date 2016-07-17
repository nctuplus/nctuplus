class CourseMapsController < ApplicationController
	#include CourseMapsHelper

	before_filter :checkCourseMapPermission, :except=>[:public, :index, :show]#, :only=>[:edit, :destroy, :update, :course_action, :action_new, :action_update, :action_delete, :action_fchange, :course_group_action, :update_cm_head, :credit_action, :notify_user] #:checkTopManager
	#before_filter :checkLogin, :only=>[:cm_public_comment_action]
##### resource controller

	def public #return json for index
		if request.format=="json"
			year=params[:year].blank? ? Semester::CURRENT.year : params[:year]
			course_map=CourseMap.where(:department_id=>params[:dept_id], :year=>year).take
			if course_map==current_user.try(:course_maps).try(:first)
				user_courses=current_user.courses_stat_table_json#current_user.courses_agreed.map{|cs|cs.to_basic_json}+current_user.courses_taked.map{|cs|cs.to_basic_json}
			end
			@res={
				:dept_name=>Department.where(:id=>params[:dept_id]).take.try(:ch_name),
				:dept_id=>params[:dept_id],
				:year=>year,#Semester.where(:id=>params[:sem_id]).take.try(:year),
				:course_map=>course_map.try(:to_public_json),
				:user_courses=>user_courses
			}
		end
		respond_to do |format|
			#format.html{}
			format.json{render json:@res}
		end
		
	end

	
	def index
	
		if params[:dept_id].present? && params[:year].present?
			course_map=CourseMap.where(:department_id=>params[:dept_id], :year=>params[:year]).take
			#if course_map.nil?
			#	redirect_to "/course_maps?not_found=true&dept_id=#{params[:dept_id]}"
			if course_map
				redirect_to "/course_maps/#{course_map.id}"
			end
		end
			#return
		#else
			@college_sel=College.includes(:departments).where("id NOT IN (8,10)").map{|college|college.name}
			@dept_sel=CourseMap.all.includes(:department).group(:department_id).map{|cm|[cm.department_ch_name,cm.department_id]}
			@year_sel=Semester::YEARS#.map{|sem|[sem.year,sem.year]}
			@depts=CourseMap.all.group(:department_id).map{|cm|cm.department}
		#end
		
	end
	
	
	def show
		@course_map=CourseMap.find(params[:id])
		@dept_id=@course_map.department_id
		@year=@course_map.year
		@college_sel=College.includes(:departments).where("id NOT IN (8,10)").map{|college|college.name}
		@dept_sel=CourseMap.all.includes(:department).group(:department_id).map{|cm|[cm.department_ch_name,cm.department_id]}
		@year_sel=Semester::YEARS#.map{|sem|[sem.year,sem.year]}
		@depts=CourseMap.all.group(:department_id).map{|cm|cm.department}
		
	end
	
	def edit
		@course_map=CourseMap.find(params[:id])
		set_content_full_width
	end

	def new
		@cm = CourseMap.all.order('name desc')
		@res={}
		@cm.each do |c|
			@res[c.id]={:year=>c.year, :dept_id=>c.department_id}
		end
		@course_map=CourseMap.new
		render "/course_maps/manage/_form"
	end

	def create	
		@course_map = CourseMap.new(course_map_params)
		@course_map.user_id=current_user.id
		@course_map.save
		if params[:copy].to_i != 0
			@course_map.copy_content_from_current(params[:copy])	# handle copy
		end
		redirect_to "/admin/course_maps"
	end
	
	def destroy
		@map = current_user.admin_cms.find(params[:id])
		@map.course_fields.destroy_all
		@map.destroy
		redirect_to "/admin/course_maps"
	end

	def update
		@course_group=CourseGroup.find(params[:id])
		@course_group.update_attributes(course_group_param)

    redirect_to :action => :index
	end
	
	def content
		@course_map = CourseMap.find(params[:map_id])
		render "/course_maps/manage/content", :layout=>false		
	end
	
	def search_course
		@degree_sel=Department.degreeSel
		if !params[:q].blank?
			#@q = CourseDetail.search(params[:q])
			@q = Course.search(params[:q])
		else
			@q = Course.search({:id_eq=>0})	
		end
		
		@courses=@q.result(distinct: true).includes(:course_details, :departments)#.map{|cd|cd.course}
		
		if params[:map_id].presence
			course_group = CourseGroup.where("gtype=0 AND course_map_id=? ",params[:map_id]).map{|cg| cg.id}
			course_group_courses = CourseGroupList.where(:course_group_id=>course_group, :lead=>0).includes(:course).map{|c| c.course}
			@courses = @courses.reject{|course| course_group_courses.include? course }
		end
		@result=@courses.map{|c|{
			:id=>c.id,
			:name=>c.ch_name,
			:cd_id=>c.is_virtual ? 0 : c.course_details.last.id,
			:real_id=>c.real_id,
			:credit=>c.credit,
			:dept_name=>c.is_virtual ? c.real_id : c.dept_name,
			:cos_type=>c.is_virtual ? "抵免" : c.course_details.last.cos_type
		}}
		render "course_maps/manage/search_course", :layout=>false
	end
	
	def get_course_tree
		if request.xhr? # if ajax
			list = []
			data = CourseMap.find(params[:map_id])
			data.course_fields.order('field_type ASC').each do |cf|	
				sub = cf.treeview_trace										
				list.push(sub)	
			end		
			list.push({:text=>'新增類別', :type=>-1, :icon=>'fa fa-plus text-success', :parent_id=>params[:map_id]})
		end# if
	
		respond_to do |format|
   		format.json {render :layout => false, :text=>list.to_json}
    end
	end
	


# handle course_field new	
	def action_new
		level = params[:level].to_i
		parent_id = params[:parent_id]
		name = params[:name]
		field_type = params[:field_type].to_i
	# new cf
		cf = CourseField.new
		cf.name, cf.field_type, cf.user_id = name, field_type, current_user.id
		cf.save!
		
	# if not 必修, add credit_need table row	
		#if field_type>=2
		credit = CfCredit.new
		credit.course_field_id=cf.id
		credit.save!
		#end
		
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

	# update course_field column
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

	# delete course_field
	def action_delete # ajax POST 
		cf = CourseField.find(params[:target_id])
		cmcf = CmCfship.where(:course_field_id=>cf.id)
		cmcf.last.destroy unless cmcf.empty?
		cfship = CourseFieldSelfship.where(:child_id=>cf.id)
		cfship.last.destroy unless cfship.empty?
		cf.destroy
		render :nothing => true, :status => 200, :content_type => 'text/html'
	end
	
	# change field_type 1<-->2 
	def action_fchange # ajax POST
		cf = CourseField.find(params[:target_id])
		cf.field_type = (cf.field_type==1) ? 2 : 1
		if cf.field_type==1
			if cf.courses.presence
				cf.credit_need = cf.courses.map{|c| c.credit.to_i}.reduce(:+)
			end
			if cf.course_groups.presence
				cf.credit_need += cf.course_groups.map{|cg| cg.lead_course.credit.to_i}.reduce(:+)
			end
		else
			cf.credit_need = 0
		end
		cf.save!
		
		render :nothing => true, :status => 200, :content_type => 'text/html'
	end
	
	def get_course_group
		cf = CourseField.find(params[:cf_id])
		data=cf.course_field_lists.where(:course_id=>nil).order("updated_at DESC").includes(:course_group, :course_group_lists, :courses, :departments).each.map{|cfl|{
			:cfl_id=>cfl.id,
			:cg_id=>cfl.course_group_id,
			:record_type=>cfl.record_type,
			:grade=> cfl.grade,
			:half=> cfl.half,
			:gtype=>cfl.course_group.gtype,
			:courses=>cfl.course_group_lists.order("lead DESC").each.map{|cgl|{
				:cgl_id=>cgl.id, 
				:course_id=>cgl.course.id ,
				:course_name=>cgl.course.ch_name,
				:dept_name=>cgl.course.dept_name,
				:real_id=>cgl.course.real_id,
				:credit=>cgl.course.credit,
			}}
		}}
		respond_to do |format|
   	 	format.json {render :json=> data}
    end
	end
	def get_course_list
		cf = CourseField.find(params[:cf_id])
		data=cf.course_field_lists.where(:course_group_id=>nil).order("updated_at DESC").includes(:courses, :departments).each.map{|cfl|
			cfl.to_cm_mange_json
		}
		respond_to do |format|
   	 	format.json {render :json=> data}
    end
	end
	def show_course_list	
		
		cf = CourseField.find(params[:target_id])
		data = []
		cf.course_field_lists.order("updated_at DESC").includes(:course).each do |list|
			course = 0
			if list.course_group_id  # it is a group header
				cg = list.course_group
				if not cg # TODO: should not go here (the cg delete proc should have deleted the related cfl)
					next 
				end
			#	leader = cg.lead_group_list
				groups = {
					:gtype=>cg.gtype,
					:courses=>[]
				}
				cg.course_group_lists.order("updated_at DESC").includes(:course).each do |cgl|				
					if cgl.lead == 1
						course = cgl.course
					else
						c = cgl.course
						tmp2 = {
							:id=>cgl.id,
							:cg_id=>cg.id,
							:course_name=>c.ch_name,
							:dept_name=> c.dept_name,#try(:department).try(:ch_name),
							:credit=> c.credit,
							:real_id=>c.real_id
						}
						groups[:courses].push(tmp2)
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
				:dept_name=>course.dept_name,#try(:department).try(:ch_name),
				:real_id=>course.real_id,
				:credit=>course.credit,
				:record_type=>list.record_type,
				:grade=> list.grade,
				:half=> list.half,
				:cg_id=>list.course_group_id,
				:group=> groups 
			 }
			
			data.push(tmp)	
		end
		
	#	Rails.logger.debug "[debug] " + data.to_s
		respond_to do |format|
   	 	format.json {render :json=> data}
    end

	end
	
	
	
	def show_course_group_list
		cg = CourseGroup.find(params[:target_id])
		data=cg.course_group_lists.order("updated_at DESC").includes(:course).map{|l|{
			:id=>l.id,
			:course_id=>l.course_id,
			:course_name=>l.course.ch_name,
			:real_id=>l.course.real_id,
			:dept_name=>l.course.dept_name,#try(:department).try(:ch_name),
			:credit=>l.course.credit,
			:leader=>(l.lead==0) ? false : true 
		}}
		
		respond_to do |format|
   	 	format.json {render :json=> data}
    end
	end
	
	def course_action # ajax 
		data = {}
		case params[:type]
			when 'create_cfl'
				c_ids = params[:c_ids]
				cf = CourseField.find(params[:cf_id])#.includes(:course_group_lists)
				cfl_same_cnt=cf.course_field_lists.where(:course_id=>c_ids).count
				cgl_same_cnt=cf.course_group_lists.where(:course_id=>c_ids).count
				data[:cfl_same_cnt], data[:cgl_same_cnt] = cfl_same_cnt, cgl_same_cnt
				data[:cfl]=[]
				c_ids.each do |c_id|
					cd=Course.find(c_id).course_details.last
					cfl=cf.course_field_lists.create(
						:user_id => current_user.id,
						:course_id => c_id,
						:grade=>cd.grade,
						:half=>cd.semester.half
					)
					data[:cfl].push(cfl.to_cm_mange_json)
				end
		
				
			when 'create_cgl'			
				cg = CourseGroup.find(params[:cg_id])
				c_ids = params[:c_ids]
				cfl_same_cnt=cg.course_field.course_field_lists.where(:course_id=>c_ids).count
				cgl_same_cnt=cg.course_group_lists.where(:course_id=>c_ids).count
				data[:cfl_same_cnt], data[:cgl_same_cnt] = cfl_same_cnt, cgl_same_cnt
				data[:cgl]=[]
				c_ids.each do |c_id|
					cgl = cg.course_group_lists.create(
						:course_id => c_id,
						:user_id => current_user.id
					)
					data[:cgl].push(cgl.to_cm_manage_json)
				end			
			when 'update'
				cfl = CourseFieldList.find(params[:cfl_id])
				if params[:target]=="grade"
					cfl.update(:grade=>params[:value])
				elsif params[:target]=="half"
					cfl.update(:half=>params[:value])
				elsif params[:target]=="record_type"
					cf=cfl.course_field
					cfl.update(:record_type => params[:rtype].to_i)
				end
				data[:success] = 1	
			when 'delete'
				cfl = CourseFieldList.find(params[:cfl_id])
				cf = cfl.course_field
				cfl.destroy
				data[:success] = 1	
			else
				data[:fail] = 1	
		end
		
		#cf.update_credit
		if cf && cf.field_type==1
			cf.update_credit
			data[:new_credit]=cf.cf_credits.first.credit_need
		end
		
		render :text=>data.to_json#, :layout=> false
	end
	
	def course_group_action #ajax POST	
		data = nil
		case params[:type]
			when 'new' # change from normal cf, and create a course group
				cfl=CourseFieldList.find(params[:cfl_id])
				cg = CourseGroup.create(
					:course_map_id=> params[:cm_id],
					:user_id=>current_user.id,
					:gtype=>0
				)
				#First course, so it's must be lead
				cg.course_group_lists.create(
					:course_id=>cfl.course_id,
					:lead=>1
				)
				#Set cfl to match new course group
				cfl.update(
					:course_id=>nil,
					:course_group_id=>cg.id
				)
				data=_get_single_cg(cg).to_json
			when 'update' # update course list type or set leader
				cg = CourseGroup.find(params[:cg_id])
				if params[:target]=='gtype'
					cg.update(:gtype => params[:gtype])
				elsif params[:target]=='leader'# leader
					cg.course_group_lists.update_all(:lead=>0)
					cg.course_group_lists.find(params[:cgl_id]).update(:lead=>1)
				end
				data={
					:new_credit=>cg.course_field.update_credit,
					:cg=>_get_single_cg(cg)
				}.to_json
			when 'delete' # delete course
				if params[:target] == 'cg'		
					CourseGroup.find(params[:cg_id]).destroy!
					data={
						:new_credit=>CourseField.find(params[:cf_id]).update_credit
					}.to_json
				elsif params[:target] == 'cgl'
					cgl = CourseGroupList.find(params[:cgl_id]).destroy!
				end
				#data = {:success=>1}.to_json
		end
		render :text=> data
	end
	
	def update_cm_head # ajax post
		cm = CourseMap.find(params[:map_id]).update_attributes(
			:department_id=> params[:dep],
			:year=> params[:year],
			:total_credit=> params[:grade],
			:desc=> params[:desc]
		)
		render :nothing => true, :status => 200, :content_type => 'text/html'
	end

	def get_credit_list
		
		res=_get_credit_list(params[:id])
		respond_to do |format|
			format.json {render :json=>res.to_json, :status => :ok}
    end
	end
	
	def credit_action
		case params[:type]
			when "update","delete"
				@credit=CfCredit.find(params[:id])			
			when "add"
				cf=CourseField.find(params[:cf_id])
				
				@credit=CfCredit.new(:course_field_id=>cf.id,:index=>cf.cf_credits.count)
		end
		case params[:type]
			when "update","add"
				@credit.memo=params[:memo]
				@credit.credit_need=params[:credit_need]
				@credit.save!
			when "delete"
				if CfCredit.where(:course_field_id=>params[:cf_id]).count > 1
					@credit.destroy!
				end
		end	
		
		res=_get_credit_list(params[:cf_id])
		
		
		respond_to do |format|
			format.json {render :json=>res.to_json, :status => :ok}
    end
		
	end
	
	def notify_user
		if request.xhr?
			cm = CourseMap.find(params[:map_id])
			UserCoursemapship.where(:course_map_id=>cm.id).update_all(:need_update=>1)
		end
		render :nothing => true, :status => 200, :content_type => 'text/html'
	end	
	
	def change_owner
		render :nothing=> true, :status=>CourseMap.find(params[:map_id]).update(:user_id => params[:uid].to_i) ? 200 : 500
	end
	
private
		
	def course_map_params
    params.require(:course_map).permit(:title, :department_id, :name, :desc, :year)
  end
	def _get_single_cg(cg)
		#cg = CourseGroup.find(cg_id)
		cfl=cg.course_field_list	
		data={
			:cfl_id=>cfl.id,
			:cg_id=>cg.id,
			:record_type=>cfl.record_type,
			:grade=> cfl.grade,
			:half=> cfl.half,
			:gtype=>cfl.course_group.gtype,
			:courses=>cg.course_group_lists.order("updated_at DESC").includes(:course).map{|cgl|{
				:cgl_id=>cgl.id, 
				:course_id=>cgl.course.id ,
				:course_name=>cgl.course.ch_name,
				:dept_name=>cgl.course.dept_name,
				:real_id=>cgl.course.real_id,
				:credit=>cgl.course.credit,
			}}
		}
		return data
		
	end

	def _get_credit_list(cf_id)
		@cf=CourseField.find(cf_id)
		if @cf.field_type>=1
			res={
				cf_type: @cf.field_type,
				credit_list:
					@cf.cf_credits.map{|credit|{
						:id=>credit.id,
						:name=>credit.memo,
						:credit_need=>credit.credit_need.to_s
					}}
				
			}
		else
			res=[]
		end
		return res
	end
	
end
