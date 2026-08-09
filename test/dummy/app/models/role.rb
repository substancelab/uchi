class Role < ApplicationRecord
  belongs_to :company
  belongs_to :person
end
