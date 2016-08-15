class CreateSlogans < ActiveRecord::Migration
  def change
    create_table :slogans do |t|
      t.text :description

      t.timestamps
    end
  end
end
