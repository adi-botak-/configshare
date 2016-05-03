=begin
acc1 = Account.new(username: 'adi-botak-', email: 'adityautamawijaya@gmail.com')
acc1.password = 'mypassword'
acc1.save
=end

acc1 = CreateNewAccount.call(
	username: 'adi-botak-',
	email: 'adityautamawijaya@gmail.com',
	password: 'mypassword')

acc2 = CreateNewAccount.call(
	username: 'lee123',
	email: 'lee@nthu.edu.tw',
	password: 'leepassword')

proj11 = AddProjectForOwner.call(
	acc1,
	name: 'Adi Project',
	repo_url: 'http://github.com/adi-botak-/project.git')
doc11 = proj11.add_configuration(filename: 'config_env.rb')
doc11.document = "this is the first line\nthis is the second line"
doc11.description = 'environmental configurations for test, development envs'
doc11.save
doc12 = proj11.add_configuration(filename: 'environments.ini')
doc12.document = '---'
doc12.save

proj12 = acc1.add_owned_project(name: 'Config Project')
doc21 = proj12.add_configuration(filename: 'credentials.json')
doc21.document = 'username: password'
doc21.save

proj21 = acc2.add_owned_project(name: 'Lee\'s Project')
acc1.add_project(proj21)
proj22 = acc2.add_owned_project(name: 'Lee\'s Solo Project')