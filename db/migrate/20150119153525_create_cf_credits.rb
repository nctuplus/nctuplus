class CreateCfCredits < ActiveRecord::Migration
  def change
    create_table :cf_credits do |t|
			t.integer :course_field_id
			t.integer :index, :default=>0
			t.integer :credit_need, :default=>0
			t.string :memo, :default=>"default"
      t.timestamps
    end
		add_index :cf_credits, :course_field_id
  end
end
