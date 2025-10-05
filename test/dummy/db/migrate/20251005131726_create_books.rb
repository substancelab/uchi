class CreateBooks < ActiveRecord::Migration[8.0]
  def change
    create_table :books do |t|
      t.string :original_title

      t.timestamps
    end
  end
end
