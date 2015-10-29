class AddIsAnonymousToPastExams < ActiveRecord::Migration
  def change
		add_column :past_exams, :is_anonymous, :boolean, :default=>false, :after=> :semester_id, :null=> false
  end
end
