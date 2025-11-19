# frozen_string_literal: true

module Uchi
  module Ui
    # Renders the main navigation menu visible at the side of the viewport.
    #
    # The template for this component has access to the following methods:
    #
    # - `items`: Returns an `Array` of `Hashes` containing :label and :path keys
    #   for each item to render in the navigation.
    # - `navigatable_repositories`: Returns an `Array` of `Uchi::Repository`
    #   instances. The `Array` is sorted alphanumerically by the
    #   `navigation_label` for each repository.
    # - `repositories`: Returns an `Array` with an instance of each
    #   `Uchi::Repository` in the application.
    class Navigation < ViewComponent::Base
      protected

      def items
        navigatable_repositories.map do |repository|
          {
            label: repository.translate.navigation_label,
            path: repository.routes.path_for(:index)
          }
        end
      end

      def navigatable_repositories
        repositories.sort_by { |repository| repository.translate.navigation_label.downcase }
      end

      def repositories
        Uchi::Repository.all.map(&:new)
      end
    end
  end
end
