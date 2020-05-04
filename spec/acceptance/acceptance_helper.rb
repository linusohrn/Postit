require_relative "../spec_helper"
require_relative "../../app.rb"
require_relative "../../handler.rb"
Dir["../../model/*"].each { |file| require_relative file }

require "capybara/minitest"
require "capybara/minitest/spec"
require "rack/test"

Capybara.app = App
Capybara.default_driver = :selenium_chrome
Capybara.server = :webrick
