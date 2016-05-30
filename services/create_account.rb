# Service object to create new accounts using all columns
class CreateAccount
	def self.call(username:, email:, password:)
		account = Account.new(username: username, email: email)
		account.password = password
		account.save
	end
end