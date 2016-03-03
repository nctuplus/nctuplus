class CreateBulletins < ActiveRecord::Migration
  def change
    create_table :bulletins do |t|

      t.references :user
      t.string :title
      t.text :article
      t.boolean :article_type
      t.timestamps
    end
  end
end
