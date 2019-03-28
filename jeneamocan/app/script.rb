require 'pry'
require 'watir'
require 'nokogiri'
require 'json'

class WebBanking
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
			puts "Enter CAPTCHA"
			browser.text_field(name: "captcha").set(gets.chomp)
		else
		end
		browser.button(class: "wb-button").click
		sleep(3)
		if browser.div(class: "block__cards-accounts").exist?
			puts "Authentication successful"
		else
			puts "Invalid username or password, try again"
			authentication
		end
	end

	def info
		browser.goto("https://web.vb24.md/wb/#menu/MAIN_215.NEW_CARDS_ACCOUNTS")
		name = browser.div(class: %w"user-info has-last-entry").span(class: "user-name").text
		balance = browser.div(class: "primary-balance").span(class: "amount").text
		currency = browser.div(class: "primary-balance").span(class: %w"amount currency").text
		puts ["**Account**", "- #{name}", " -#{currency}", "- #{balance}"]
	end
end

class Accounts < WebBanking
	def account_info
		if browser.text_field(name: "login").present?
			puts "Authentication required"
			authentication
		else
		end
		browser.a(href: "#menu/MAIN_215.NEW_CARDS_ACCOUNTS").click
		name = browser.div(class: %w"user-info has-last-entry").span(class: "user-name").text
		balance = browser.div(class: "primary-balance").span(class: "amount").text
		currency = browser.div(class: "primary-balance").span(class: %w"amount currency").text
		puts JSON.pretty_generate ({"accounts": [name: name, currency: currency, balance: balance]})
	end
end

class Transactions < WebBanking
	def last_transaction
		if browser.text_field(name: "login").present?
			puts "Authentication required"
			authentication
		else
		end
		browser.a(href: "#menu/MAIN_215.CP_HISTORY").click
		month = browser.div(class: "month-delimiter").text
		day = browser.div(class: "day-header").text.split[0]
		date = day + " " + month
		time = browser.span(class: "history-item-time").text
		description = browser.a(class: "operation-details").text
		amount = browser.span(class: %w"history-item-amount transaction").text
		puts JSON.pretty_generate ({"transactions": [date: date, time: time, description: description, amount: amount]})
	end
end

jeneamocan = Accounts.new
jeneamocan.run

binding.pry