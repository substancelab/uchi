# frozen_string_literal: true

require_relative "action/configuration"

module Uchi
  # Base class for all Uchi actions.
  #
  # Actions allow you to perform custom operations on one or more records from
  # a repository. Examples include publishing posts, exporting data, or sending
  # notifications.
  #
  # To create an action, subclass this class and implement the `perform` method:
  #
  #   class PublishPost < Uchi::Action
  #     def perform(records, input = {})
  #       records.each { |record| record.update!(published: true) }
  #       Uchi::ActionResponse.success("Published #{records.size} posts")
  #     end
  #   end
  #
  # Actions are registered on repositories via the `actions` method:
  #
  #   class PostRepository < Uchi::Repository
  #     def actions
  #       [PublishPost.new]
  #     end
  #   end
  class Action
    include Configuration

    # @return [Uchi::Context] the context in which the action is performed
    attr_accessor :context

    # Returns the display name for this action.
    #
    # By default, this looks up the translation key
    # `uchi.action.[action_key].name` and falls back to the humanized class
    # name.
    #
    # @return [String]
    def name
      translate(:name, default: self.class.name.demodulize.titleize)
    end

    # Returns this action's visual style, used to color its icon (see
    # #icon_classes) so appearance stays consistent regardless of whether
    # the action renders as a button, a link, or a form's submit button.
    #
    # @return [Symbol] One of :default, :danger
    def style
      :default
    end

    # Returns the list of fields to show in the action form.
    #
    # Fields are instances of Uchi::Field subclasses (e.g., Field::String,
    # Field::Boolean).
    #
    # @return [Array<Uchi::Field>]
    def fields
      []
    end

    # Performs the action on the given records.
    #
    # This method must be implemented in subclasses.
    #
    # @param records [ActiveRecord::Relation, Array] - The records to operate on
    # @param input [Hash] - Hash of field values from the action form
    # @return [Uchi::ActionResponse]
    def perform(records, input = {})
      raise NotImplementedError, "#{self.class}#perform must be implemented"
    end

    # Returns the HTML necessary for executing the action.
    #
    # By default, actions are rendered as a button that, when clicked, submits
    # a POST request to execute the action (see #perform). Override this
    # method to render the action differently, e.g. as a plain link (see
    # Uchi::Action::Edit).
    #
    # @param record [Object] - The record the action would apply to
    # @param repository [Uchi::Repository] - The repository the record belongs to
    # @param view [ActionView::Base] - The view context for rendering
    # @return [String] HTML for executing the action
    def render(record:, repository:, view:)
      view.form_with(url: view.actions_executions_path, method: :post, class: "block") do
        view.safe_join([
          view.hidden_field_tag(:model, repository.model.name),
          view.hidden_field_tag(:action_name, self.class.name),
          view.hidden_field_tag(:id, record.id),

          view.button_tag(
            type: "submit",
            class: "block inline-flex items-center w-full p-2 hover:bg-neutral-tertiary-medium hover:text-heading rounded"
          ) do
            name
          end
        ])
      end
    end

    # Returns the HTML necessary for executing the action, styled as a
    # standalone primary button/link, for use when it's the only action
    # available (see Uchi::Ui::Actions::Dropdown).
    #
    # By default, this looks like #render but styled with the Flowbite
    # button classes matching #style, instead of the menu item styling used
    # when this action appears alongside others in a dropdown. Override
    # this method to render the action differently, e.g. as a plain link
    # (see Uchi::Action::Edit).
    #
    # @param record [Object] - The record the action would apply to
    # @param repository [Uchi::Repository] - The repository the record belongs to
    # @param view [ActionView::Base] - The view context for rendering
    # @return [String] HTML for executing the action
    def button_render(record:, repository:, view:)
      view.form_with(url: view.actions_executions_path, method: :post, class: "inline-block") do
        view.safe_join([
          view.hidden_field_tag(:model, repository.model.name),
          view.hidden_field_tag(:action_name, self.class.name),
          view.hidden_field_tag(:id, record.id),

          view.button_tag(name, type: "submit", class: Uchi::Flowbite::Button.classes(style: style))
        ])
      end
    end

    # Returns the HTML necessary for executing the action, for use in a records
    # table row (see Uchi::Ui::Index::RecordsTable).
    #
    # By default, actions in a table row are rendered as an icon-only button
    # that, when clicked, submits a POST request to execute the action (see
    # #perform), using #icon for its appearance. Override this method to render
    # the action differently in a table row, e.g. as a link (see
    # Uchi::Action::Edit).
    #
    # @param record [Object] - The record the action would apply to
    # @param repository [Uchi::Repository] - The repository the record belongs to
    # @param view [ActionView::Base] - The view context for rendering
    # @return [String] HTML for executing the action
    def row_render(record:, repository:, view:)
      view.form_with(url: view.actions_executions_path, method: :post, class: "inline-block") do
        view.safe_join([
          view.hidden_field_tag(:model, repository.model.name),
          view.hidden_field_tag(:action_name, self.class.name),
          view.hidden_field_tag(:id, record.id),

          view.button_tag(
            type: "submit",
            class: icon_classes,
            title: name
          ) do
            icon(view)
          end
        ])
      end
    end

    # Returns the icon to display for this action in icon-only contexts
    # (see #row_render).
    #
    # Defaults to the "play" icon from Flowbite Icons
    # (https://flowbite.com/icons/). Override to use a different icon, e.g.
    # the "trash-bin" icon (see Uchi::Action::Delete).
    #
    # @param view [ActionView::Base] - The view context for rendering
    # @return [String] SVG markup for the icon
    def icon(view)
      view.tag.svg(
        "aria-hidden": "true",
        class: "w-6 h-6",
        fill: "none",
        height: "24",
        viewBox: "0 0 24 24",
        width: "24",
        xmlns: "http://www.w3.org/2000/svg"
      ) do
        view.tag.path(
          d: "M8 18V6l8 6-8 6Z",
          stroke: "currentColor",
          "stroke-linecap": "round",
          "stroke-linejoin": "round",
          "stroke-width": "2"
        )
      end
    end

    # Returns true if this action requires input fields.
    #
    # @return [Boolean]
    def requires_input?
      fields.any?
    end

    private

    # Tailwind requires class names to appear as complete, literal strings
    # somewhere in the source so its content scanner can find them -- so
    # this can't be assembled by interpolating the style into a shared
    # string.
    ICON_CLASSES = {
      default: "inline-block cursor-pointer hover:text-fg-brand",
      danger: "inline-block cursor-pointer hover:text-fg-danger"
    }.freeze

    # Returns the CSS classes used for an icon-only action, so a button, a
    # link, or a form's submit button all look and behave identically:
    # a hand cursor and a hover style matching #style.
    #
    # @return [String]
    def icon_classes
      ICON_CLASSES.fetch(style)
    end

    # Looks up i18n key with fallback
    # @param key [Symbol] - the key to look up (e.g., :name)
    # @param default [String] - fallback value
    # @param options [Hash] - additional i18n options (count, etc.)
    # @return [String, nil]
    def translate(key, default:, **options)
      i18n_key = "action.#{translation_key}.#{key}"
      Uchi::I18n.translate(i18n_key, default: default, **options)
    end

    # Returns the i18n key segment for this action
    # Example: PublishPost -> "publish_post"
    def translation_key
      self.class.name.underscore.tr("/", ".")
    end
  end
end
