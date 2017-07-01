class MainController < ApplicationController
 after_action :allow_iframe, only: :fb

  def calendar
  end

  def fb
  end

	def test
		#@courses=BookTradeInfo.search({:colleges_id_eq=>0}).result(:distinct=>true)
		#@courses=PastExam.search({:colleges_id_eq=>2}).result(:distinct=>true)
	end

 	def index
		if current_user && (current_user.year==0 || current_user.department.nil?)
			alertmesg('info','warning', "請填寫系級" )
			redirect_to "/user/edit"
		end
    time = Time.now.utc
    @news = Bulletin.where("article_type AND (!hidden_type OR (hidden_type AND \"#{time}\" > begin_time AND \"#{time}\" < end_time))").reverse_order()
    @updates = Bulletin.where("!article_type AND (!hidden_type OR (hidden_type AND \"#{time}\" > begin_time AND \"#{time}\" < end_time))").reverse_order()
    @slogans = Slogan.where("!hidden_type").limit(1).order("rand()")
    if !params[:bid].nil?
      @backgrounds = Array(Background.find(params[:bid]))
    else
      @backgrounds = Background.all
    end
    @checkimg = (!params[:bid].nil?  && current_user && !current_user.isNormal?)

  end

	def get_specified_classroom_schedule
  	if params[:token_id]=="ems5566"
  		@data = CourseDetail.where(:semester_id=>Semester::LAST.id, :room=>params[:room]).includes(:course)	
  		respond_to do |format|
   	 		format.json { render :layout => false, :text => @data.map{|d| [d.course.ch_name, d.time, d.reg_num] }.to_json }
    	end
    end
  end	
  	
	def member_intro
		
	end
  
  private

  def allow_iframe
    response.headers.except! 'X-Frame-Options'
  end

end
