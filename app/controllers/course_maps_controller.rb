class CourseMapsController < ApplicationController
	#include CourseMapsHelper

	before_filter :checkCourseMapPermission, :except=>[:index, :public, :cm_public_comment_action, :course_action, :action_new, :action_update, :action_delete, :action_fchange, :course_group_action, :update_cm_head, :credit_action] #:checkTopManager
	before_filter :checkLogin, :only=>[:cm_public_comment_action]
##### resource controller

	def public #return json for index
		if request.format=="json"
			year=params[:year].blank? ? Semester::CURRENT.year : params[:year]
			course_map=CourseMap.where(:department_id=>params[:dept_id], :year=>year).take
			
			@res={
				:dept_name=>Department.where(:id=>params[:dept_id]).take.try(:ch_name),
				:dept_id=>params[:dept_id],
				:year=>year,#Semester.where(:id=>params[:sem_id]).take.try(:year),
				:course_map=>course_map.nil? ? nil : {
					:id => course_map.id,
					#:name => course_map.department.ch_name+"入學年度:"+course_map.semester.year.to_s,
					:total_credit=>course_map.total_credit,
					:desc => course_map.desc,
					:cfs=>course_map.to_tree_json,
					:comments=>course_map.comments
				}
			}
		end
		respond_to do |format|
			#format.html{}
			format.json{render json:@res}
		end
		
	end
	
	# handle Q&A post (ajax)
	def cm_public_comment_action
		res = []
		if request.post?
			if params[:type]=="reply"
				if params[:parent_id].to_i==0
					res = CourseMapPublicComment.create(
						:course_map_id => params[:cm_id],
						:user_id => current_user.id,
						:comments => params[:comment]
					)
				else
					res = CourseMapPublicSubComment.create(
						:course_map_id => params[:cm_id],
						:user_id => current_user.id,
						:comments => params[:comment],
						:course_map_public_comment_id=> params[:parent_id]
					)
				end
			elsif params[:type]=="check"
				res = CourseMapPublicComment.find(params[:qa_id])
				res.checked = true
				res.save!
			end	
		end
		
		render :text=>res.to_hash.to_json, :layout=>false 
	end
	
	def index
	
		if !params[:dept_id].blank?
			@dept=Department.where(:id=>params[:dept_id]).take
			if !@dept.try( :majorable? )
				redirect_to "/course_maps/"
				return
			end
		end

		@depts=CourseMap.all.group(:department_id).map{|cm|cm.department}
		respond_to do |format|
			format.html{}
		end		
	end
	
	def show
		@course_map=CourseMap.find(params[:id])
	end

	def new
		@res={}
		@cm = CourseMap.all.order('name desc')
		@cm.each do |c|
			@res[c.id]={:year=>c.year, :dept_id=>c.department_id}
		end
		
		@course_map=CourseMap.new
		render "_form"
	end

	def create	
		@course_map = CourseMap.create(
			:year=> params[:year] || 0	,
			:name=> params[:name],
			:department_id=> params[:course_map][:department_id],
			:desc=> params[:course_map][:desc],
			:user_id=> current_user.id
		)

# handle copy 		
		if params[:copy].to_i != 0
			copy_from = CourseMap.find(params[:copy])
			@course_map.update_attributes(:total_credit=>copy_from.total_credit)
			
			#Rails.logger.debug "[debug] in1 "+copy_from.course_fields.count.to_s
			copy_from.course_fields.each do |cf|
				#Rails.logger.debug "[debug] cfcfcf"
				new_cf = CourseField.create(
					:user_id=>current_user.id,
					:name=>cf.name,
					:color=>cf.color,
					:field_type=>cf.field_type
				) 
				
				cmcfship = CmCfship.create(:course_map_id=>@course_map.id, :course_field_id=>new_cf.id)
				
				if cf.field_type==3 #copy cf_field_needs
					cffneed = CfFieldNeed.create(:course_field_id=>new_cf.id, :field_need=>cf.field_need)
					
				end
				
				#copy cf_credits
				
				
				trace_cm(new_cf, cf, :_copy_cfl_and_credit)
			end
			
			copy_from.course_groups.each do |cg|
				new_cg = CourseGroup.create(
					:user_id=>current_user.id,
					:course_map_id=>@course_map.id,
					:gtype => cg.gtype 
				)
				
				cg.course_group_lists.each do |cgl|
					new_cgl = CourseGroupList.create(
						:user_id=>current_user.id,
						:course_group_id=>new_cg.id,
						:course_id=>cgl.course_id,
						:lead =>  cgl.lead
					)
					
				end
			end
			
		end
		redirect_to "/admin/course_maps"
	end
	
	def destroy
		@map = CourseMap.find(params[:id])
		@map.destroy
		redirect_to "/admin/course_maps"
	end
	
	def edit
	end

	def update
		@course_group=CourseGroup.find(params[:id])
		@course_group.update_attributes(course_group_param)

    redirect_to :action => :index
	end
	
	def course_map_content
		@course_map = CourseMap.find(params[:map_id])
		render :layout=>false		
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
	
	def show_course_list	
		
		cf = CourseField.find(params[:target_id])
		data = []
		
		cf.course_field_lists.includes(:course).each do |list|
			course = 0
			if list.course_group_id  # it is a group header
				cg = list.course_group
			#	leader = cg.lead_group_list
				groups = []
				cg.course_group_lists.includes(:course).each do |cgl|				
					if cgl.lead == 1
						course = cgl.course
					else
						c = cgl.course
						tmp2 = {
							:course_name=>c.ch_name,
							:dep=> c.try(:department).try(:ch_name),
							:credit=> c.credit,
							:real_id=>c.real_id
						}
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
				:dep=>course.try(:department).try(:ch_name),
				:real_id=>course.real_id,
				:credit=>course.credit,
				:record_type=>list.record_type,
				:grade=> list.grade,
				:half=> list.half,
				:groups=> groups 
			 }
			
			data.push(tmp)	
		end
		
	#	Rails.logger.debug "[debug] " + data.to_s
		respond_to do |format|
   	 	format.json {render json: data}
    end

	end
	
	def show_course_group_list
		cg = CourseGroup.find(params[:target_id])
		data=cg.course_group_lists.includes(:course).map{|l|{
			:id=>l.id,
			:course_id=>l.course_id,
			:course_name=>l.course.ch_name,
			:real_id=>l.course.real_id,
			:dep=>l.course.try(:department).try(:ch_name),
			:credit=>l.course.credit,
			:leader=>(l.lead==0) ? false : true 
		}}
		
		respond_to do |format|
   	 	format.json {render json: data}
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
=begin
					if all_courses.include? c_id.to_i #check same
						fail_cnt +=1
						next
					end
=end				
					cfl = CourseFieldList.new
					cfl.course_field_id = cf.id
					cfl.user_id = current_user.id
					
					# check course group
					hit = course_group_leads.select{|d1, d2| d2==c_id.to_i}
					if not hit.empty?
						cg_id=hit.last[0]
						cfl.course_group_id = cg_id
						cd=CourseGroup.find(cg_id).lead_course.course_details.last
					else	
						cfl.course_id = c_id
						cd=Course.find(c_id).course_details.last						
					end
					cfl.grade=cd.grade
					cfl.half=cd.semester.half
					cfl.save
				
					success_cnt += 1
				end
				#cf.save!
				#cf.update_credit					
				data[:success], data[:fail] = success_cnt, fail_cnt
			when 'add_group'
				cg = CourseGroup.find(params[:cg_id])
				c_ids = params[:c_ids]
				all_courses = cg.course_group_lists.map{|li| li.course_id}
				fail_cnt = 0
				success_cnt = 0
				has_lead = (cg.lead_group_list.presence) ? true : false
				c_ids.each do |c_id|
=begin
					if all_courses.include? c_id.to_i #check same
						fail_cnt +=1
						next
					end
=end
					cgl = CourseGroupList.new
					cgl.course_group_id, cgl.course_id = cg.id, c_id
					cgl.user_id= current_user.id
					cgl.lead = (has_lead) ? 0 : 1
					cgl.save!
					success_cnt += 1
				end

				data[:success], data[:fail] = success_cnt, fail_cnt	
			when 'update'
				if params[:rtype].to_i ==2 # update grade or half
					cfl = CourseFieldList.find(params[:target_id])
					cfl[params[:target]] = params[:value]
					cfl.save!
				else
					cfl = CourseFieldList.find(params[:target_id])
					cf=cfl.course_field
					cfl.record_type = params[:rtype].to_i
					cfl.save
				end
				data[:success] = 1	
			when 'delete'
				cf = CourseField.find(params[:cf_id])
				cfl = CourseFieldList.find(params[:target_id])		
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
			when 'new' # new course group
				cg = CourseGroup.create(
					:course_map_id=> params[:map_id],
					:user_id=>current_user.id,
					:gtype=>0
				)
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
	
private
	
	def _get_credit_list(cf_id)
		@cf=CourseField.find(cf_id)
		if @cf.field_type>=1
			res={
				cf_type:@cf.field_type,
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
	
  def trace_cm(target, cf, funcA)
	#if cf.field_type < 3
			send(funcA, target.id, cf)	
	#else 	
		cf.child_cfs.each do |sub|
			new_cf = CourseField.create(
				:user_id=>current_user.id,
				:name=> sub.name,
				:credit_need=>sub.credit_need,
				:color=>sub.color,
				:field_type=>sub.field_type
			)
			cfship = CourseFieldSelfship.create(:parent_id=>target.id, :child_id=>new_cf.id)
			if new_cf.field_type==3
				cffneed = CfFieldNeed.create(:course_field_id=>new_cf.id, :field_need=>0)
			end
			trace_cm(new_cf, sub, funcA)
		end
	#end
	return
  end

  def _copy_cfl_and_credit(target_id, cf)
		cf.course_field_lists.each do |cfl|
			CourseFieldList.create(
				:user_id=>current_user.id, 
				:course_field_id=>target_id,
				:course_id=>cfl.course_id,
				:record_type=>cfl.record_type,
				:course_group_id=>cfl.course_group_id,
				:grade=>cfl.grade,
				:half=>cfl.half
			)
			
		end
		cf.cf_credits.each do |credit|
			CfCredit.create(
				:course_field_id=>target_id,
				:index=>credit.index,
				:memo=>credit.memo,
				:credit_need=>credit.credit_need
			)
		end
  end

=begin  
  def _get_field_content_data(cf)		
		chead = (cf.field_type==1) ? "[必修] " : "[X選Y] "
		data = {
			:text=>(chead+cf.name),
			:type=>cf.field_type,
			:cf_id=>cf.id,
			:label=>chead, 
			:name=>cf.name,
			:icon => (cf.field_type==3) ? "fa fa-star" : "fa fa-check-square-o",
			#:credit_need => (cf.field_type==3) ? "N/A" : cf.cf_credits.first.credit_need,			
			:tag=>cf.field_type==2 ? [cf.credit_need.to_s] : ""
		}  

		return data
  end
=end  
	
=begin  
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
=end
  
	
end
