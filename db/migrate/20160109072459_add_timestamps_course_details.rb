class AddTimestampsCourseDetails < ActiveRecord::Migration
  def change
		add_timestamps(:course_details)
  end
end
