class User < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :login, null: false
      t.integer :age
      t.text :description
    end
  end
end
