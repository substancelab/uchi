class CreateAuthors < ActiveRecord::Migration[8.0]
  def change
    create_table :authors do |t|
      t.string :name
      t.text :biography
      t.date :born_on

      t.timestamps
    end
  end
end
