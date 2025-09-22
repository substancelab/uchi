# frozen_string_literal: true

module Uchi
  class Field
    class Blank < Field
      class Edit < Uchi::Field::Base::Edit
      end

      class Index < Uchi::Field::Base::Index
      end

      class Show < Uchi::Field::Base::Show
      end
    end
  end
end
