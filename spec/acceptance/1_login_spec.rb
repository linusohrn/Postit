require "byebug"
require "sqlite3"
require_relative "acceptance_helper"
require_relative "../../handler.rb"
Dir["../../model/*"].each { |file| require_relative file }

class LoginProfileSpec < Minitest::Spec
  include ::Capybara::DSL
  include ::Capybara::Minitest::Assertions

  def self.test_order
    :alpha
  end

  before do
    visit "/"
  end

  after do
    Capybara.reset_sessions!
  end

  it "user login" do
    within("#login_form") do
      fill_in("username", with: "admin")
      fill_in("password", with: "admin")
      click_button "Login!"
    end

    sleep 1
    _(page).must_have_css(".message")

    find("a", text: "profile").click

    sleep 1

    _(page).must_have_css(".settings")
  end
end
