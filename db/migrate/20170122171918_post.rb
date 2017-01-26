class Post < ActiveRecord::Migration[5.0]
  def change
    create_table :posts do |t|
      t.string :title, null: false
      t.text :text, null: false
      t.belongs_to :user, index: true
    end
  end
end
