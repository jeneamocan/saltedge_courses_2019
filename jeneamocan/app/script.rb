require 'pry'
require 'watir'
require 'nokogiri'

def browser
	@browser ||= Watir::Browser.new :chrome
end

def run
	browser.goto("https://web.vb24.md/wb/")
	authentication
end

def authentication
	puts "Enter your login"
	browser.text_field(name: "login").set(gets.chomp)
	puts "Enter your password"
	browser.text_field(name: "password").set(gets.chomp)
	if browser.text_field(name: "captcha").present?
		puts "Enter Captcha"
		browser.text_field(name: "captcha").set(gets.chomp)
	else
	end
	browser.button(class: "wb-button").click
	sleep(3)

	if browser.div(class: "block__cards-accounts").exist?
		nil
	else
		puts "Invalid username or password, try again"
		authentication
	end
end

run
