class AddBriefNewToCourseDetails < ActiveRecord::Migration
  def change
    add_column :course_details, :brief_new, :string
  end
end
