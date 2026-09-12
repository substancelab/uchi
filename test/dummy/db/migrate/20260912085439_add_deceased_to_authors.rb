class AddDeceasedToAuthors < ActiveRecord::Migration[8.1]
  def change
    add_column :authors, :deceased, :boolean, default: false, null: false
  end
end
