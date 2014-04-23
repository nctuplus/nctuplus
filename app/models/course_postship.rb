class CoursePostship < ActiveRecord::Base
  belongs_to :course
  belongs_to :post
  def self._create(post_id,list,attr) #eng_name's list
    if !list.empty?
	  list.each do|tag|
	    @course=Course.where(:eng_name=>tag).first
		if !@course.blank?
	      @cp=CoursePostship.new
		  @cp.post_id=post_id
		  @cp.course_id=@course.id
		  @cp.save!
		end
	  end
	end
  end
  def self._destroy_by_postid(post_id)
    @cp = CoursePostship.where(:post_id=>post_id)
	if !@cp.empty?
	  @cp.destroy_all
	  #@cp.each do |r|
	  #  r.destroy
	  #end
	end
  end
end
