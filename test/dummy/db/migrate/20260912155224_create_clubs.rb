class CreateClubs < ActiveRecord::Migration[8.1]
  def change
    create_table :clubs, primary_key: :club_id do |t|
      t.string :name
      t.timestamps
    end
  end
end
