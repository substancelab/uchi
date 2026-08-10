class Person < ApplicationRecord
  has_many :roles, dependent: :destroy
  has_many :companies, through: :roles
end
