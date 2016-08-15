class CourseMap < ActiveRecord::Base
	#has_many :course_field_groups, :dependent => :destroy
	
	has_many :course_fields, :through => :cm_cfships
	has_many :course_groups, :dependent => :destroy
	has_many :cm_cfships, :dependent => :destroy
	has_many :user_coursemapships, :dependent => :destroy
	
	belongs_to :department
	delegate :ch_name, :to=>:department, :prefix=>true
	belongs_to :user
	delegate :name, :to=>:user, :prefix=>true
	def to_public_json
		{
			:id => self.id,
			#:name => course_map.department.ch_name+"入學年度:"+course_map.semester.year.to_s,
			:total_credit=>self.total_credit,
			:desc => self.desc,
			:cfs=>self.to_tree_json,
			:user=>{
				:name=>self.user.try(:name),
				:uid=>self.user.try(:uid)
			}
		}
	end
	
	
	def to_tree_json
		self.course_fields.includes(:course_field_lists, :courses, :child_cfs, :cf_credits).map{|cf|
			cf.field_type < 3 ? cf.get_bottom_node : cf.get_middle_node
		}	
	end

  def copy_content_from_current(copy_from_cmid)
    copy_from = CourseMap.find(copy_from_cmid)
    
    self.total_credit = copy_from.total_credit  
    if self.desc.empty?
      self.desc = copy_from.desc
    end
    self.save!
    
    copy_from.course_fields.each do |cf|
      new_cf = CourseField.create(
        :user_id=>self.user_id,
        :name=>cf.name,
        :color=>cf.color,
        :field_type=>cf.field_type
      ) 
      
      cmcfship = CmCfship.create(:course_map_id=>self.id, :course_field_id=>new_cf.id)
      
      if cf.field_type==3 #copy cf_field_needs
        cffneed = CfFieldNeed.create(:course_field_id=>new_cf.id, :field_need=>cf.field_need)		
      end				
      #copy cf_credits			
      _trace_cm(new_cf, cf, :_copy_cfl_and_credit)
    end
  
  end

private

  def _trace_cm(target, cf, funcA)		
    # create cfl 
    send(funcA, target.id, cf)	 
    
    # create nested cf
		cf.child_cfs.each do |sub|
			new_cf = CourseField.create(
				:user_id=>self.user_id,
				:name=> sub.name,
				:credit_need=>sub.credit_need,
				:color=>sub.color,
				:field_type=>sub.field_type
			)
			cfship = CourseFieldSelfship.create(:parent_id=>target.id, :child_id=>new_cf.id)
			if new_cf.field_type==3
				cffneed = CfFieldNeed.create(:course_field_id=>new_cf.id, :field_need=>0)
			end
			_trace_cm(new_cf, sub, funcA)
		end
	
  end
  
  def _copy_cfl_and_credit(target_id, cf)
		cf.course_field_lists.each do |cfl|
      # Check if is course group. If so create it
      cg_id = nil 
      if !cfl.course_group_id.nil?
        cg = cfl.course_group
        new_cg = CourseGroup.create(
					:user_id=>self.user_id,
					:course_map_id=>self.id,
					:gtype => cg.gtype 
				)  
        
        cg.course_group_lists.each do |cgl|
					new_cgl = CourseGroupList.create(
						:user_id=>self.user_id,
						:course_group_id=>new_cg.id,
						:course_id=>cgl.course_id,
						:lead =>  cgl.lead
					)					
				end        
        
        cg_id = new_cg.id
      end
 
			CourseFieldList.create(
				:user_id=>self.user_id, 
				:course_field_id=>target_id,
				:course_id=>cfl.course_id,
				:record_type=>cfl.record_type,
				:course_group_id=>cg_id,
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
  
end
