class CreateCfFieldNeed < ActiveRecord::Migration
  def change
    create_table :cf_field_need do |t|
			t.integer :course_field_id
			t.integer :field_need
      t.timestamps
    end
  end
end
