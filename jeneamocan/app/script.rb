require 'pry'
require 'watir'
require 'nokogiri'
require 'open-uri'
require 'json'

class WebBanking

	BASE_URL	= "https://web.vb24.md/wb/"
	DATA_DIR 	= "data"

	def browser
		@browser ||= Watir::Browser.new :chrome
	end

	def run
		browser.goto(BASE_URL)
		authentication_check
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

	def authentication_check
		if browser.text_field(name: "login").present?
			puts "Authentication required"
			authentication
		else
		end
	end

	def info
		browser.goto("https://web.vb24.md/wb/#menu/MAIN_215.NEW_CARDS_ACCOUNTS")
		name = browser.div(class: "main-info").a(class: "name").text
		balance = browser.div(class: "primary-balance").span(class: "amount").text
		currency = browser.div(class: "primary-balance").span(class: %w"amount currency").text
		nature = browser.div(class: %w"section-title h-small").text.downcase.capitalize
		puts ["**Account**", "- #{name}", "- #{currency}", "- #{balance}", "- #{nature}"]
	end
end

class Accounts < WebBanking

	attr_reader :account

	def initialize
		browser.goto(BASE_URL)
		authentication_check
		account_info
		store
	end

	def account_info
		@account = account_check
	end

	def account_check
		authentication_check
		puts "Fetching account informatrion"
		browser.goto("https://web.vb24.md/wb/#menu/MAIN_215.NEW_CARDS_ACCOUNTS")
		name = browser.div(class: "main-info").a(class: "name").text
		balance = browser.div(class: "primary-balance").span(class: "amount").text
		currency = browser.div(class: "primary-balance").span(class: %w"amount currency").text
		nature = browser.div(class: %w"section-title h-small").text.downcase.capitalize
		{self.class.name.downcase => [name: name, currency: currency, balance: balance, nature: nature]}
	end

	def store
		Dir.mkdir(DATA_DIR) unless File.exists?(DATA_DIR)
   		file_name = "#{DATA_DIR}/#{File.basename('account')}.json"
      	File.open(file_name, 'w'){|file| file.write(@account.to_json)}
       	puts "Saved to #{file_name}"
	end

end

class Transactions < WebBanking

	attr_reader :transaction

	def transaction_info
		@transaction = last_transaction
	end

	def initialize
		browser.goto(BASE_URL)
		authentication_check
		transaction_info
		store
	end

	def last_transaction
		authentication_check
		puts "Fetching latest transaction"
		browser.goto("https://web.vb24.md/wb/#menu/MAIN_215.CP_HISTORY")
		month = browser.div(class: "month-delimiter").text
		day = browser.div(class: "day-header").text.split[0]
		time = browser.span(class: "history-item-time").text
		date = day + " " + month + " " + time
		description = browser.a(class: "operation-details").text
		amount = browser.span(class: %w"history-item-amount transaction").text
		{self.class.name.downcase => [date: date, description: description, amount: amount]}
	end

	def store
		Dir.mkdir(DATA_DIR) unless File.exists?(DATA_DIR)
   		file_name = "#{DATA_DIR}/#{File.basename('transactions')}.json"
      	File.open(file_name, 'w'){|file| file.write(@transaction.to_json)}
       	puts "Saved to #{file_name}"
    end

end

account 	= Accounts.new
transaction = Transactions.new