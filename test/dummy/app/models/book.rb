class Book < ApplicationRecord
  has_and_belongs_to_many :authors
  has_many :titles

  accepts_nested_attributes_for :titles, allow_destroy: true, reject_if: :all_blank

  has_many_attached :samples
  has_one_attached :cover
end
