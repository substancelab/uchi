class Book < ApplicationRecord
  has_and_belongs_to_many :authors
  has_many :titles

  has_one_attached :sample
  has_one_attached :cover
end
