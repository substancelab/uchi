class CreateTitles < ActiveRecord::Migration[8.0]
  def change
    create_table :titles do |t|
      t.string :title
      t.belongs_to :book, null: false, foreign_key: true
      t.string :locale

      t.timestamps
    end
  end
end
