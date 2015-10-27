class CourseField < ActiveRecord::Base
	belongs_to :course_field_selfship
	belongs_to :user
	has_one :cm_cfship, :dependent => :destroy#, foreign_key: "child_id"
	has_one :course_map, :through=> :cm_cfship
	has_many :course_field_lists, :dependent => :destroy
	has_many :courses, :through=> :course_field_lists
	
	
	has_many :course_groups, :through =>:course_field_lists
	has_one :cm_cfship
	has_one :cf_field_need
	
	has_many :child_course_fieldships, :dependent => :destroy, foreign_key: "parent_id", :class_name=>"CourseFieldSelfship"
	has_many :child_cfs, :through=> :child_course_fieldships, :dependent => :destroy
	
	has_one :parent_course_fieldship, :dependent => :destroy, foreign_key: "child_id", :class_name=>"CourseFieldSelfship"
	has_one :parent_cf, :through =>:parent_course_fieldship

	has_many :cf_credits, :dependent => :destroy
	
	def cfl_to_json
		
		ret={
			:courses=>[],
			:course_groups=>[]
		}
		
		self.course_field_lists.order(:grade).order(:half).each do |cfl|
			if !cfl.course.nil?			
				temp=cfl.course.to_json_for_stat
				temp[:grade]=cfl.grade=="*" ? "9" : cfl.grade
				temp[:half]=cfl.half=="*" ? "9" : cfl.half
				temp[:suggest_sem]=cfl.suggest_sem
				ret[:courses].push(temp)
			elsif !cfl.course_group.nil?
				cg=cfl.course_group
				next if cg.gtype!=0				
				ret[:course_groups].push({
					:id=>cg.id,
					:credit=> cg.lead_course.credit,
					:lead_course=>cg.lead_course.to_json_for_stat.merge({
						:suggest_sem=>cfl.suggest_sem,
						:grade=>cfl.grade=="*" ? "9" : cfl.grade,
						:half=>cfl.half=="*" ? "9" : cfl.half
					}),
					:grade=>cfl.grade=="*" ? "9" : cfl.grade,
					:half=>cfl.half=="*" ? "9" : cfl.half,
					:courses=>cg.courses_to_json.map{|course|course.merge(
						:suggest_sem=>cfl.suggest_sem,
						:grade=>cfl.grade=="*" ? "9" : cfl.grade,
						:half=>cfl.half=="*" ? "9" : cfl.half
					)}
				})
			end
		end
		return ret
		
	end
	
=begin	
	def courses_to_json
		
		ret=[]
		#course=[]
		#cg=[]
		self.course_field_lists.order(:grade).order(:half).each do |cfl|
			next if cfl.course.nil?
			temp=cfl.course.to_json_for_stat
			temp[:grade]=cfl.grade
			temp[:half]=cfl.half
			temp[:suggest_sem]=cfl.suggest_sem
			ret.push(temp)
		end
		return ret
		
	end
	
	def course_groups_to_json
		ret=[]
		self.course_field_lists.each do |cfl|
			cg=cfl.course_group
			next if cg.nil? || cg.gtype!=0
			
			temp={
				:id=>cg.id,
				:credit=> cg.lead_course.credit,
				#:lead_course_name=>cg.lead_course.ch_name,
				#:lead_course_id=>cg.lead_course.id,
				:lead_course=>cg.lead_course.to_json_for_stat.merge({
					:grade=>cfl.grade,
					:half=>cfl.half,
					:suggest_sem=>cfl.suggest_sem
				}),#_get_course_struct(cg.lead_course),
				:grade=>cfl.grade,
				:half=>cfl.half,
				:courses=>cg.courses_to_json#_get_courses_struct(cg.courses)
			}
			#temp=cfl.course.to_json_for_stat
			#temp[:grade]=cfl.grade
			#temp[:half]=cfl.half
			ret.push(temp)
		end
		return ret
		
	end
=end	
	def field_need
		if self.cf_field_need
			return cf_field_need.field_need
		else
			return nil	
		end
	end

	def update_credit
		if self.field_type==1
			self.reload
			credit=0
			self.course_field_lists.each do |cfl|
				if cfl.record_type==true
					if cfl.course
						credit+=cfl.course.credit
					elsif cfl.course_group
						credit+=cfl.course_group.lead_course.credit
					end
				end
			end
			
			self.cf_credits.first.update_attributes(:credit_need=>credit)
		end
	end
	
	def get_bottom_node
		xxx=self.cfl_to_json
		return {
  		:id=>self.id,
			:cf_name=>self.name,
			:credit_need=>self.cf_credits.first.credit_need,
			:credit_list=>self.cf_credits.order(:index).map{|credit|{
				:name=>credit.memo,
				:credit_need=>credit.credit_need
			}},
			:cf_type=>self.field_type,
			:courses=>xxx[:courses],
			:course_groups=>xxx[:course_groups]
			#:courses=>self.courses_to_json,
			#:course_groups=>self.course_groups_to_json
		}
		
  end
	def get_middle_node
		{
  		:id=>self.id,
			:cf_name=>self.name,
			:cf_type=>self.field_type,
			:field_need=>self.field_type==3 ? self.field_need : self.child_cfs.count,
			:credit_list=>self.cf_credits.order(:index).map{|credit|{
				:name=>credit.memo,
				:credit_need=>credit.credit_need
			}},
			:credit_need=>self.cf_credits.first.credit_need,
			:child_cf=>self.child_cfs.includes(:courses).map{|child_cf|
				child_cf._get_cf_tree(:get_bottom_node, :get_middle_node)
			}
		}
  end
	
	def treeview_trace 
		return _treeview_trace(self, :_get_field_content_data, :_get_add_field_node)
	end
	
protected
	
	def _get_cf_tree(funcA, funcB)
		return _cf_trace(self, funcA, funcB)
	end
	
	# recursive
	def _cf_trace(cf, funcA, funcB=nil)
  	if cf.field_type < 3
			data = send(funcA)	
		else 
			nodes = []
			cf.child_cfs.order('field_type ASC').each do |sub|
				nodes.push(_cf_trace(sub, funcA, funcB))
			end
			data= send(funcB) if funcB
		end
		return data
  end
	
	def _treeview_trace(cf, funcA, funcB)
		if cf.field_type < 3
			data = send(funcA, cf)	
		else 
			nodes = []
			cf.child_cfs.order('field_type ASC').each do |sub|
				nodes.push(_treeview_trace(sub, funcA, funcB))
			end
			data= send(funcB, cf, nodes) if funcB
		end
		return data
	end
	

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
	
	def _get_add_field_node(cf, nodes)
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
