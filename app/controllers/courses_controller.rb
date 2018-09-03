class CoursesController < ApplicationController

  before_filter :checkLogin, :only=>[:simulation, :add_simulated_course, :del_simu_course]

  def index
    @sem_sel=Semester.all.order("id DESC").pluck(:name, :id)
    if params[:custom_search].present? || params[:q].present?	#if query something
      @q = CourseDetail.search_by_q_and_text(params[:q],params[:custom_search])
    elsif current_user.try(:department_id) && current_user.department.has_courses # e.x 資工系資工組/網多/資電
      @q = CourseDetail.search({:department_id_eq=>current_user.department_id})
    else	
      @q = CourseDetail.search({})
    end
    cds=@q.result(distinct: true).includes(:course, :course_teachership, :semester, :department)
    @cds=cds.page(params[:page]).order("semester_id DESC").order("view_times DESC")

    # 產生通識課程的課名縮寫
    @tags_by_id= {}
    @cds.each do |cd|
        tags_of_a_course = []
        
        # 舊制通識
        if not cd.brief.strip.empty?
            # 移除資料後綴年份 e.g. "體育必修(87)"-> "體育必修"
            trimmed_name = cd.brief.sub(/\(\s*\d+\s*\)/,'').strip
            if not trimmed_name.empty?
                tags_of_a_course.append( {:name=> trimmed_name, :title=>cd.brief, :label_type=>'label-default'} )
            end
        end

        # 針對新制通識
        #   abbrev: abbreviation
        abbrev_dict = {
            :校基本素養 => { :name=> '通識校基本', :label_type=>'label-primary'},
            :跨院基本素養 => { :name=> '通識跨院', :label_type=>'label-info'}
        }

        # 測試用
        #brief_str = "核心-自然(106),跨院基本素養(106),校基本素養(106)"

        brief_str = cd.brief_new || ""
        if not brief_str.empty?
            puts "brief_str: #{brief_str}"
            brief_str_array = brief_str.split(',')
            brief_str_array.each do |full_name|
                trimmed_name = full_name.sub(/\(\s*\d+\s*\)/,'').to_sym
                if abbrev_dict.key?(trimmed_name)
                    h = abbrev_dict[trimmed_name]
                    h[:title] = full_name
                    tags_of_a_course.append(h)
                else
                    # 核心類別
                    tags_of_a_course.append( {:name=>trimmed_name,:title=>full_name, :label_type=>'label-warning'} )
                end
            end
        end
        if not tags_of_a_course.empty?
            @tags_by_id[ cd.id ] = tags_of_a_course
        end
    end
    
  end

  def search_mini	#for course simulation search & result
    if !params[:dimension_search].blank?	#search by 向度 (推薦系統)
      @q= CourseDetail.search({:semester_id_eq=>Semester::LAST.id, :brief_cont_any=>JSON.parse(params[:dimension_search])})
    elsif !params[:timeslot_search].blank? #search by time (推薦系統)
      @q= CourseDetail.search({:cos_type_cont_any=>["通識","外語"], :semester_id_eq=>Semester::LAST.id, :time_cont_any=>JSON.parse(params[:timeslot_search])})
    elsif !params[:custom_search].blank? #search by text
      @q = CourseDetail.search_by_q_and_text(params[:q],params[:custom_search])
    elsif !params[:required_search].blank? #search required courses
      c_ids = find_required_courses_id
      highest_score_ct = Course.where(:id=>c_ids).map{|c| c.to_require_search}.select {|i| i != 0}
      @q = CourseDetail.search(:semester_id_eq=>Semester::LAST.id, :course_id_in=>c_ids)
    else
      if params[:q].blank?
        @q=CourseDetail.search({:id_in=>[0]})
      else
        @q=CourseDetail.search(params[:q])				
      end
    end
    cds=@q.result(distinct: true).includes(:course, :course_teachership, :semester, :department)
    @result={
      :view_type=>"simulation",
      :use_type=>"add",
      :add_to_cart=>true,
      :courses=>cds.map{|cd|
        cd.to_search_result
      }
    }
    @result[:highest_score_ct] = highest_score_ct if !params[:required_search].blank? 
    render "courses/search/mini", :layout=>false
  end




  def export_timetable
    sem_id=params[:sem_id].to_i
    @sem=Semester.find(sem_id)
    cd_ids=current_user.courses_taked.search_by_sem_id(sem_id).map{|ps| ps.course_detail.id}
    @course_details=CourseDetail.where(:id=>cd_ids).order(:time)

    respond_to do |format|
      format.xls{
        response.headers['Content-Type'] = "application/vnd.ms-excel"
        response.headers['Content-Disposition'] = " attachment; filename=\"#{@sem.name}.xls\" "	
      }
    end
  end	

  def count_times(ch_name, array)
    count_hash = {}
    array.each do |key|
      if count = count_hash[key]
        count_hash[key] = count + 1
      else
        count_hash[key] = 1
      end
    end
    count_hash[ch_name] = 0 #should not pick this course itself
    trivial_courses = ['導師時間','服務學習','服務學習(一)','服務學習(二)','基礎程式設計','程式設計','計算機概論（一）','計算機概論（二）','計算機概論','計算機概論與程式設計','微積分甲（一）','微積分甲（二）','微積分乙（一）','微積分乙（二）','微積分丙（一）','微積分丙（二）','微積分A（一）','微積分A（二）','微積分B（一）','微積分B（二）','物理(一)','物理(二)','化學(一)','化學(二)','大一英文（一）','大一英文（二）','大一體育','藝文賞析教育']
    trivial_courses.each do |t|
      count_hash[t] = 0
    end
    return count_hash
  end

  def extract_keys_with_largest_n_values(hash, n)
    n = hash.length if n > hash.length
    min = hash.values.sort[-n]
    results = []
    i = 0
    hash.each{|k, v| (results.push(k) and i += 1) if i < n and v >= min}
    return results
  end

  def get_recommend_courses(ch_name, students)
    courses_they_take = []
    scores = NormalScore.where( :user_id => students )
    scores.each do |s|
      courses_they_take << s.course.ch_name
    end
    count_hash = count_times(ch_name, courses_they_take)
    ch_names = extract_keys_with_largest_n_values( count_hash, 5)
    results = []
    ch_names.each do |ch_name|
      results << { "id"=>Course.find_by_ch_name(ch_name).course_details.sort_by{|s| -s[:semester_id]}.first.id, "name"=>ch_name }
    end
    return results
  end


  def show
    cd=CourseDetail.includes(:course_teachership, :course, :semester, :department, :normal_scores).find(params[:id])	
    incViewTime(cd)
    @list_type=[["[考試]",1],["[作業]",2],["[上課]",3],["[其他]",4]]
    @data = {
      :course_id=>cd.course.id.to_s,
      :course_detail_id=>cd.id.to_s,
      :course_teachership_id=>cd.course_teachership.id.to_s,
      :course_name=>cd.course_ch_name,
      :course_teachers=>cd.teacher_name,
      :course_real_id=>cd.course.real_id.to_s,
      :temp_cos_id=>cd.temp_cos_id,
      :year=>cd.semester_year,
      :half=>cd.semester_half,
      :course_credit=>cd.course.credit,
      :open_on_latest=>(cd.course_teachership.course_details.last.semester_id==Semester::LAST.id) ? true : false ,
      :related_cds=>cd.course_teachership.course_details.includes(:semester,:department).order("semester_id DESC"),
      :updated_at=>cd.updated_at,
      :recommend_courses=>get_recommend_courses(cd.course.ch_name, cd.normal_scores.pluck("user_id" ))
    }
    #render "/course_content/show"
  end

  def simulation  
    @degree_sel=[['大學部','3'],['研究所','2'],['大學部共同','0']]
    @dept_sel=Department.searchable.pluck(:ch_name, :id)
    @q=CourseDetail.search({:id_in=>[0]})
  end

  def add_to_cart
    cd_id=params[:cd_id].to_i
    cd_to_add = CourseDetail.find(cd_id)
    #cd_ids=JSON.parse(cookies.signed[:cd])
    if params[:type]=="add"
      if CourseDetail.where(:id=>cd_id).empty?
        alt_class="warning"
        mesg="查無此門課!"
      else
        unless current_user.course_details.include?(cd_to_add)
          current_user.course_details << cd_to_add
          alt_class="success"
          mesg="新增成功!"
        else
          alt_class="info"
          mesg="您已加入此課程!"		
        end
      end
    else
      if current_user.course_details.include?(cd_to_add)
        current_user.course_details.delete(cd_to_add)
        alt_class="success"
        mesg="刪除成功!"
      else
        alt_class="warning"
        mesg="你未加入此課程!"
      end
    end
    respond_to do |format|
      format.json {
        render :json => {:class=>alt_class, :text=>mesg}
      }
    end
  end

  def show_cart
    @result={
      :view_type=>params[:view_type],
      :use_type=>params[:use_type],#"delete",
      :add_to_cart=>params[:add_to_cart]=='1',
      :courses=>current_user.course_details.map{|cd|
        cd.to_search_result
      }
    }
    respond_to do |format|
        format.json{ render :json => @result[:courses].to_json}
        format.html{ render :layout=>false}
    end
  end


  private

  def incViewTime(cd)
    current_time = Time.new
    c_id=cd.id.to_s
    session[:course]={} if session[:course].nil?
    if session[:course][c_id] != current_time.day
      session[:course][c_id] = current_time.day
      cd.incViewTimes!
    end
  end

  def course_param
    params.require(:course).permit(:ch_name, :eng_name, :department_id)
  end

  def find_required_courses_id
    grade = (Semester::LAST.year - current_user.year + 1).to_s
    half = Semester::LAST.half.to_s
    cf_ids = CmCfship.where(:course_map_id => current_user.course_map_ids).distinct.pluck(:course_field_id)
    c_ids, cg_ids = CourseFieldList.includes(:course_field).where(:grade => grade, :half => half, :course_fields => {:id => cf_ids, :field_type => 1 }).distinct.pluck(:course_id, :course_group_id).transpose
    c_ids = [] if c_ids.nil?
    c_ids += CourseGroupList.includes(:course_group).where(:course_group_id => cg_ids ).distinct.pluck(:course_id) << 0 #防止cid裡沒有資料
    return c_ids
  end

end

