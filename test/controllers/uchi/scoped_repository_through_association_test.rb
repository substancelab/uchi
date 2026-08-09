require "test_helper"

module Uchi
  class ScopedRepositoryThroughAssociationTest < ActionDispatch::IntegrationTest
    setup do
      @company = Company.create!(name: "Acme, Inc.")
      @scope = {model: "Company", id: @company.id, field: "people"}
    end

    test "GET new does not render a field for the scoped parent record" do
      get new_uchi_person_url(scope: @scope)
      assert_select "input[name='person[company_ids][]']", count: 0
    end

    test "GET new renders a form that posts back with the scope preserved" do
      get new_uchi_person_url(scope: @scope)

      assert_select "form[action=?]", uchi_people_path(scope: @scope)
    end

    test "submitting the rendered new form associates the new record with the scoped parent record" do
      get new_uchi_person_url(scope: @scope)
      form_action = Nokogiri::HTML5(response.body).at_css("form[method='post']")["action"]

      post form_action, params: {person: {name: "Bilbo Baggins"}}

      assert_equal [@company], Person.last.companies
    end

    test "POST create associates the new record with the scoped parent record via the join model" do
      post uchi_people_url(scope: @scope), params: {
        person: {name: "Bilbo Baggins"}
      }

      assert_equal [@company], Person.last.companies
    end

    test "POST create redirects back to the scoped parent record on success" do
      post uchi_people_url(scope: @scope), params: {
        person: {name: "Bilbo Baggins"}
      }

      assert_redirected_to uchi_company_path(id: @company.id)
    end
  end
end
