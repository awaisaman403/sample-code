class CreateHotels < ActiveRecord::Migration[5.0]
  def change
    create_table :hotels do |t|
      t.string :name, null: false
      t.string :phone, null: false
      t.string :external_id, null: false

      t.index :external_id, unique: true
      t.index :phone, unique: true
      t.timestamps
    end
  end
end
