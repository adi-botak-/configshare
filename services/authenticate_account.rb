require 'jose'

# Find account and check password
class AuthenticateAccount
  def self.call(signed_credentials)
    credentials = SecureClientMessage.verified_data(signed_credentials)
    account = Account.first(username: credentials['username'])
    raise 'Credentials not found' unless passwords_match(account, credentials)
    [account, SecureClientMessage.encrypt(account)]
  end

  private_class_method

  def self.passwords_match(account, credentials)
    account && account.password?(credentials['password'])
  end
end