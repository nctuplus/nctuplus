class CreatePreSchedules < ActiveRecord::Migration
  def change
    create_table :pre_schedules do |t|

      t.timestamps
    end
  end
end
