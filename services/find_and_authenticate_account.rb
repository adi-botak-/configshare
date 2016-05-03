# Find account and check password
class FindAndAuthenticateAccount
	def self.call(username:, password:)
		return nil unless username && password

		account = Account.where(username: username).first
		account && account.password?(password) ? account : false
	end
end