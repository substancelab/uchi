# frozen_string_literal: true

class AddAuthorBooksJoinTable < ActiveRecord::Migration[8.0]
  def change
    create_join_table :authors, :books do |t|
      t.index [:author_id, :book_id]
    end
  end
end
