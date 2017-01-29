class ChangeDb2 < ActiveRecord::Migration[5.0]
  def change
  	change_table :users do |t|
      t.change :login, :string, null: false, uniqueness: true
    end
  end
end
