class ChangeDb < ActiveRecord::Migration[5.0]
  def change
  	change_table :posts do |t|
      t.change :title, :string, null: false
      t.change :text, :text, null: false      
    end
  end
end
