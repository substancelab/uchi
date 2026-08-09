class Company < ApplicationRecord
  has_many :roles, dependent: :destroy
  has_many :people, through: :roles
end
