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
    within("#login_form") do
      fill_in("username", with: "admin")
      fill_in("password", with: "admin")
      click_button "Login!"
      sleep 1
    end
  end

  after do
    Capybara.reset_sessions!
  end

  it "has messages and subsequent components" do
    _(page).must_have_css(".message")
  end

  it "write new message" do
    @time = Time.now.to_s

    within(".message-post") do
      sleep 1
      text_area = first(:css, "textarea.post-box")
      text_area.send_keys(@time)
      sleep 1
      find('input[id="Admin post"]').click
      sleep 1
      find('input[id="Release notes"]').click
      sleep 1
      click_button("Post it!")
      sleep 1
    end
    msg = page.find("p", exact_text: @time).find(:xpath, "..")
    _(msg).must_have_content(@time)
    _(msg).must_have_content("Admin post")
    _(msg).must_have_content("Release notes")
  end

  it "reply to message" do
    but = page.find("div", id: "message_id=3").click_button("Reply")

    @time = Time.now.to_s

    within(".message-post") do
      sleep 1
      text_area = first(:css, "textarea.post-box")
      text_area.send_keys(@time)
      sleep 1
      find('input[id="Admin post"]').click
      sleep 1
      find('input[id="Announcement"]').click
      sleep 1
      click_button("Post it!")
      sleep 1
    end
    msg = page.find("p", exact_text: @time).find(:xpath, "..")
    _(msg).must_have_content(@time)
    _(msg).must_have_content("Admin post")
    _(msg).must_have_content("Announcement")
    _(msg).must_have_content(">>3")
  end
end
