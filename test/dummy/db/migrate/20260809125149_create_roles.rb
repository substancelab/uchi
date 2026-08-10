class CreateRoles < ActiveRecord::Migration[8.1]
  def change
    create_table :roles do |t|
      t.references :company, null: false, foreign_key: true
      t.references :person, null: false, foreign_key: true
      t.string :title

      t.timestamps
    end
  end
end
