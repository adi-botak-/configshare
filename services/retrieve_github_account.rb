require 'http'

# Find or create an SsoAccount based on Github code
class RetrieveSsoAccount
  def self.call(code)
    access_token = get_access_token(code)
    github_account = get_github_account(access_token)
    sso_account = find_or_create_sso_account(github_account)

    [sso_account, JWE.encrypt(sso_account)]
  end

  private_class_method

  def self.get_access_token(code)
    HTTP.headers(accept: 'application/json').post('https://github.com/login/oauth/access_token',
    	form: {
    		client_id: ENV['GH_CLIENT_ID'],
    		client_secret: ENV['GH_CLIENT_SECRET'],
    		code: code
    		}).parse['access_token']
  end

  def self.get_github_account(access_token)
    gh_account = HTTP.headers(
    	user_agent: 'Config Secure',
    	authorization: "token #{access_token}",
    	accept: 'application/json').get('https://api.github.com/user').parse
    { username: gh_account['login'], email: gh_account['email'] }
  end

  def self.find_or_create_sso_account(github_account)
    SsoAccount.first(github_account) || SsoAccount.create(github_account)
  end
end