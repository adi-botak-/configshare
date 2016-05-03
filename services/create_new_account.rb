# Service object to create new accounts using all columns
class CreateNewAccount
	def self.call(username:, email:, password:)
		account = Account.new(username: username)
		account.email = email
		account.password = password
		account.save
	end
end