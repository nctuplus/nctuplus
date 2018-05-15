class Course < ActiveRecord::Base
	belongs_to :grade
	#belongs_to :department#, :class_name=>"NewDepartment"
	belongs_to :user

	has_many :course_field_lists
	validates_associated :course_field_lists
	has_many :course_fields, :through=>:course_field_lists
	has_many :course_teacherships, :dependent => :destroy
	validates_associated :course_teacherships
	has_many :course_details, :through=> :course_teacherships
	has_many :semesters, :through => :course_details
	has_many :departments, :through => :course_details
	has_many :colleges, :through => :departments
	def self.create_from_import_fail(data)
		
		arr=data.split('/')
		Course.find_or_create_by(:real_id=>arr[0]) do |course|
			course.credit=arr[1].to_i
			course.ch_name=arr[2]
			course.department_id=0
			course.is_virtual=true
		end
		
	end
	
	def dept_name
		self.departments.pluck("DISTINCT ch_name").join(",")
	end
	
	def to_json_for_stat
		{
			:ct_id=>self.is_virtual ? "0" :  self.course_teacherships.take.id,
			:name=>self.ch_name,
			:id=>self.id,
			:credit=>self.credit,
			#:dept=>self.department ? self.department.ch_name : "",
			:real_id=>self.real_id
		}
	end	
	
	def to_chart(last_sem)
        # 回傳特定課程不同老師的歷史開課資料統計

		# 拿取該課程最近開過課的五個學期，分別的學期名稱跟學期id
        #  因為是歷史課程,所以排除當前學期的課程(last_sem)
        #  e.g. [ {id:16, name:"104上", ... }, {id:19, name:"105上", ...}, ...]
		sems=self.semesters.order(:id).uniq.last(5).reject{ |s| s==last_sem}

        # 擷取學期名稱跟id
		sem_name_list = sems.map{ |s| s.name}
		sem_id_list = sems.map{ |s| s.id}
		if sem_id_list.length == 5
			sem_id_list.shift
			sem_name_list.shift
		end

        # 拿取所有相同課程的course_detail 結果(一次要求所有出現學期的資料)
		related_crs_dtls = self.course_details.where(:semester_id=>sem_id_list).order(:semester_id)
        
        # 拿取所有修課生的期末成績
		simu = NormalScore.where(:course_detail_id=>tmp.map{|ctd| ctd.id})

		res = []
		res_score = []
		show_score = false
        # 先將課程依據老師來分類
		related_crs_dtls.map{ |ctd|
            {   :teacher=>ctd.teacher_name,
                :cdid=>ctd.id,
                :num=>ctd.reg_num,
                :sem=>ctd.semester_id
            }
        }.group_by{ |t|
            t[:teacher]
        }.each do |k1, k2|
            # 不同開課學期的修課人數
			tmp_num = [0,0,0,0]

			tmp_score = [{:y=>0,:nums=>1},{:y=>0,:nums=>1},{:y=>0,:nums=>1},{:y=>0,:nums=>1}]
			k2.each do |hash|
				tmp_num[sem_id_list.index(hash[:sem])] = hash[:num].to_i
				score_sum = 0 
				score_count = 0
				simu.select{|sim| sim.semester_id==hash[:sem]&&sim.course_detail_id==hash[:cdid]}.each do |s|
					if s.try(:score) =~ /[[:digit:]]/ #and s.score.to_i >=60
						score_sum+= s.score.to_i
						score_count+=1
						show_score = true
					end
				end
					#	Rails.logger.debug "[debug] "+@sem_name_list.to_s
				tmp_score[sem_id_list.index(hash[:sem])][:y] = (score_count==0) ? 0 : score_sum/score_count*1.0
				tmp_score[sem_id_list.index(hash[:sem])][:nums] = score_count
			end
			res.push({:name=>k1, :data=>tmp_num})
			res_score.push({:name=>k1, :data=>tmp_score})
		end
		return {
			:show_reg=>(res.count > 0),
			:show_score=>show_score,
			:semester_name=>sem_name_list, 
			:reg_data=>res, 
			:score_data=>res_score
		}
	end
	
	def self.get_from_e3(data)
		#create a new course if cos_code wasn't found in current,
		#otherwise, return an existing one
		Course.find_or_create_by(:real_id=>data["cos_code"]) do |course|
			course.real_id=data["cos_code"]
			course.ch_name=data["cos_cname"]
			course.eng_name=data["cos_ename"]
			course.credit=data["cos_credit"].to_i
		end
	end

  def to_require_search
    #return the highest score's course_detail_id
    cts_id = self.course_details.where(:semester_id=>Semester::LAST.id).pluck(:course_teachership_id)
    cds = CourseDetail.where(:course_teachership_id=>cts_id).order(:semester_id).reverse.select {|cd| cd.semester_id != Semester::LAST.id }.uniq{|cd| cd.course_teachership_id}
    return 0 if cds.size == 1
    cd_id = 0
    highest_score = 0
    cds.each do |cd|
      score = cd.normal_scores.where.not(:score=>"修習中").average(:score).to_i
      if score > highest_score
        hightest_score = score
        cd_id = cd.course_teachership.course_details.order(semester_id: :desc).pluck(:id).first
      end
    end
    return cd_id
	end

end
